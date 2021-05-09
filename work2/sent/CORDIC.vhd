-------------------------------------------------------------------------
-- Design unit: CORDIC
-- Description: CORDIC top (Control path + Data path)
--------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.CORDIC_package.all;

entity CORDIC is
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
		start		: in std_logic;
		data_av		: in std_logic;
		data        : in std_logic_vector (7 downto 0);
		data_mem    : in std_logic_vector (31 downto 0);
        done		: out std_logic;
        MEM 		: out std_logic;
        i   		: out std_logic_vector (7 downto 0);
        sen         : out std_logic_vector (31 downto 0);
        cos         : out std_logic_vector (31 downto 0)
	);

end CORDIC;

architecture structural of CORDIC is

    signal zero, neg: std_logic;
    signal cmd: Command;

begin
    -- Conexoes entre processador CORDIC e o ControlPath
    CONTROL_PATH: entity work.ControlPath
		port map (
			clk		    => clk,
			rst		    => rst,
			cmd         => cmd,
			neg         => neg,
			zero        => zero,
			start       => start,
			data_av     => data_av,
			done        => done,
			MEM         => MEM
    );

    -- Conexoes entre processador CORDIC e o DataPath
	DATA_PATH: entity work.DataPath
		port map (
            clk		    => clk,
			rst		    => rst,
			cmd         => cmd,
			neg         => neg,
			zero        => zero,
            data        => data,
            data_mem    => data_mem,
            i           => i,
            sen         => sen,
            cos         => cos
        );
end structural;

architecture comportamental of CORDIC is
	signal a, it, aux_i, x, y, sA, neg : std_logic_vector(31 downto 0);
	type State is (S0, S1, S2, S3, S4, S5);
    signal currentState: State;

begin
	process (clk, rst)
	begin
		if rst = '1' then				-- Reset assíncrono: retorna para o estado S0
			currentState	<= S0;
		elsif rising_edge(clk) then
			case currentState is
				when S0 =>							-- Estado S0: inicialização dos reg's e a=(data<<=24)
					done	<= '0';
					a		<= data & x"000000";
					x		<= x"009b74ed";
					y		<= (others => '0');
					aux_i  	<= (others => '0');
					it      <= (others => '0');
					i		<= (others => '0');
					sA		<= (others => '0');
					neg     <= (others => '0');
					if data_av = '1' then			-- Se o dado inserido for válido pula para o estado S1
						currentState <= S1;
					else							-- Se inválido permanece no mesmo estado
						currentState <= S0;
					end if;

				when S1 =>							-- Estado S1: it = data
					it	<= x"000000" & data;
					if data_av = '1' then			-- Se o número de iterações inserido for válido vai para o estado S1
						currentState <= S2;
					else							-- Se inválido permanece no mesmo estado
						currentState <= S1;
					end if;

				when S2 =>							-- Estado S2: aguarda start = 1 para começar o cálculo
					if start = '1' then				-- Se start = '1' vai pro próximo estado e começa a calcular
						currentState <= S3;
					else
						currentState <= S2;
					end if;

				when S3 =>							-- Estado S3: faz (it - i)
					if (it - aux_i) = 0 then		-- Se (it - i) = 0, cálculo terminado, vai para o estado final
						currentState <= S5;
						done		 <= '1';
						cos			 <= x;
						sen			 <= y;
					else							-- Se (it > i) continua calculando
						neg			 <= sA - a;		-- Flag de negativo (sumAngle - angle)
						currentState <= S4;			-- Pula para o estado S4
					end if;

				when S4 =>							-- Estado S4: efetua as operações do cálculo
					if neg(31) = '1' then			-- Se angle > sumAngle
						x 	 <= x  - STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(y), TO_INTEGER(UNSIGNED(aux_i(7 downto 0)))));	-- x = x - y>>i
						y 	 <= y  + STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(x), TO_INTEGER(UNSIGNED(aux_i(7 downto 0)))));	-- y = y + x>>i
						sA	 <= sA + data_mem;	-- sumAngle = sumAngle + angleTable[i]
					else
						x 	 <= x  + STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(y), TO_INTEGER(UNSIGNED(aux_i(7 downto 0)))));	-- x = x + y>>i
						y 	 <= y  - STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(x), TO_INTEGER(UNSIGNED(aux_i(7 downto 0)))));	-- y = y - x>>i
						sA	 <= sA - data_mem;	-- sumAngle = sumAngle - angleTable[i]
					end if;

					currentState	 <= S3;						-- Volta para o Estado S3
					aux_i			 <= aux_i + 1;				-- i++
					i				 <= aux_i(7 downto 0) + 1;	-- Endereça a memória, para a próxima iteração,
																-- com I = I + 1

				when others =>						-- Estado S5: estágio final, daqui retorna para o início e fica
					currentState 	 <= S0;			-- pronto para recomeçar
					done			 <= '0';

			end case;
		end if;
	end process;
	MEM <= '1' when currentState = S3 else '0';
end comportamental;

