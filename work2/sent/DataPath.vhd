-------------------------------------------------------------------------
-- Design unit: DataPath
-- Description: CORDIC data path
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.CORDIC_package.all;


entity DataPath is
	port (
        cmd         : in Command;
        clk		    : in std_logic;
        rst         : in std_logic;
        data        : in std_logic_vector(7 downto 0);
        data_mem    : in std_logic_vector(31 downto 0);
        sen         : out std_logic_vector(31 downto 0);
        cos         : out std_logic_vector(31 downto 0);
        zero        : out std_logic;
        neg         : out std_logic;
        i           : out std_logic_vector(7 downto 0)
	);
end DataPath;


architecture behavioral of DataPath is
    signal n_reg_ang, n_reg_it, n_reg_xNew, n_reg_yNew, n_reg_x, n_reg_y, n_reg_i, n_reg_sumAngle : std_logic_vector(31 downto 0);
    signal data_ext, data_sft, soma_out, mux1, mux2, mux3, mux4, muxi : std_logic_vector(31 downto 0);
    signal mux1_adder, mux2_adder, shiftr_out : std_logic_vector(31 downto 0);
    signal i5 : natural;
begin
        -- Registradores
        reg_ang: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_ang_rs_xySa,
            d       => data_sft,
            q       => n_reg_ang
        );

        reg_it: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_it_rs_i,
            d       => data_ext,
            q       => n_reg_it
        );

        reg_xNew: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_xNew_rs_shifr,
            d       => soma_out,
            q       => n_reg_xNew
        );

        reg_yNew: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_yNew,
            d       => soma_out,
            q       => n_reg_yNew
        );

        reg_x: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_xy,
            d       => mux1,
            q       => n_reg_x
        );

        reg_y: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_xy,
            d       => mux2,
            q       => n_reg_y
        );

        reg_i: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_i,
            d       => mux3,
            q       => n_reg_i
        );

        reg_sumAngle: entity work.RegisterNbits
        generic map (
            WIDTH   => 32
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => cmd.wr_sA,
            d       => mux4,
            q       => n_reg_sumAngle
        );

        -- Extensao do dado inserido pelo usuario de 8 para 32 bits
        data_ext <= x"000000" & data;

        -- Shift 24 no dado de entrada (fator de escala do CORDIC)
        data_sft <= data & x"000000";

        -- MUXs que controlam as entradas dos registradores {x, y, i, sumAngle}
        mux1 <=     x"009b74ed" when cmd.wr_ang_rs_xySa = '1' else n_reg_xNew;
        mux2 <= (others => '0') when cmd.wr_ang_rs_xySa = '1' else n_reg_yNew;
        mux3 <= (others => '0') when cmd.wr_it_rs_i = '1'     else soma_out;
        mux4 <= (others => '0') when cmd.wr_ang_rs_xySa = '1' else soma_out;

        -- Sub-circuito SHIFT RIGHT i, que realiza (x>>i) ou (y>>i)
        muxi       <= n_reg_y when cmd.wr_xNew_rs_shifr = '1' else n_reg_x;
        i5         <= TO_INTEGER(UNSIGNED(n_reg_i(4 downto 0)));
        shiftr_out <= STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(muxi),i5));

        -- Sub-circuito SOMADOR
        -- Reune todas as operacoes e organiza as entradas do somador atraves dos MUXs
        mux1_adder <=   x"00000001" when cmd.rs_m1 = "000" else
                            n_reg_x when cmd.rs_m1 = "001" else
                            n_reg_y when cmd.rs_m1 = "010" else
                           n_reg_it when cmd.rs_m1 = "011" else
                     n_reg_sumAngle when cmd.rs_m1 = "100" else
                     (others => '0');
        mux2_adder <=      data_mem when cmd.rs_m2 = "000" else
                         shiftr_out when cmd.rs_m2 = "001" else
                            n_reg_i when cmd.rs_m2 = "010" else
                       not data_mem when cmd.rs_m2 = "100" else
                     not shiftr_out when cmd.rs_m2 = "101" else
                        not n_reg_i when cmd.rs_m2 = "110" else
                      not n_reg_ang when cmd.rs_m2 = "111" else
                     (others => '0');

        -- Somador com as entradas dos MUXs descritos acima e o carry caso seja subtracao
        soma_out <= mux1_adder + mux2_adder + cmd.rs_m2(2);

        -- Flags de zero e negativo da soma realizada
        neg <= soma_out(31);
        zero <= '1' when soma_out = 0 else '0';

        -- Saidas {i, cos, sen} para o processador CORDIC
        i   <= n_reg_i(7 downto 0);
        cos <= n_reg_x;
        sen <= n_reg_y;

end behavioral;
