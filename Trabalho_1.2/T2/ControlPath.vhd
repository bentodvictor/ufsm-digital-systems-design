-------------------------------------------------------------------------
-- Design unit: Controlpath
-- Description: CORDIC control path
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.CORDIC_package.all;

entity ControlPath is
    port (
        clk			    : in std_logic;
		rst			    : in std_logic;
        start           : in std_logic;
        data_av         : in std_logic;
        neg             : in std_logic;
        zero            : in std_logic;
        done            : out std_logic;
        MEM             : out std_logic;

        cmd             : out Command
	);
end ControlPath;

architecture behavioral of ControlPath is
   type State is (S00, S01, S02, S03, S04, S05, S06, S07, S08, S09, S10, S11, S12);
   signal currentState, nextState: State;

begin
    -- State memory
    process(clk,rst)
    begin
        if rst = '1' then
            currentState <= S00;

        elsif rising_edge(clk) then
            currentState <= nextState;

        end if;
    end process;

    -- Next state logic
    process(currentState,zero,neg,start,data_av)
    begin

        case currentState is
            when S00 =>
                if data_av = '1' then
                    nextState <= S01;
                else
                    nextState <= S00;
                end if;

            when S01 =>
                if data_av = '1' then
                    nextState <= S02;
                else
                    nextState <= S01;
                end if;

            when S02 =>
                if start = '1' then
                    nextState <= S03;
                else
                    nextState <= S02;
                end if;

            when S03 =>
                if zero = '0' then
                    nextState <= S04;
                elsif zero = '1' then
                    nextState <= S12;
                else
                    nextState <= S03;
                end if;

            when S04 =>
                if neg = '0' then
                    nextState <= S08;
                elsif neg = '1' then
                    nextState <= S05;
                else
                    nextState <= S04;
                end if;

            when S05 =>
                nextState <= S06;

            when S06 =>
                nextState <= S07;

            when S07 =>
                nextState <= S11;

            when S08 =>
                nextState <= S09;

            when S09 =>
                nextState <= S10;

            when S10 =>
                nextState <= S11;

            when S11 =>
                nextState <= S03;

            when S12 =>
                nextState <= S00;
        end case;

    end process;

    -- Output logic
    cmd.wr_ang_rs_xySa <= '1' when currentState = S00 else '0';
    cmd.wr_xy <= '1' when (currentState = S00 or currentState = S11) else '0';
    cmd.wr_sA <= '1' when (currentState = S00 or currentState = S10 or currentState = S07) else '0';
    cmd.wr_it_rs_i <= '1' when currentState = S01 else '0';
    cmd.wr_i <= '1' when (currentState = S01 or currentState = S11) else '0';
    cmd.wr_xNew_rs_shifr <= '1' when (currentState = S05 or currentState = S08) else '0';
    cmd.wr_yNew <= '1' when (currentState = S06 or currentState = S09) else '0';
    cmd.rs_m1 <= "011" when currentState = S03
            else "100" when (currentState = S04 or currentState = S07 or currentState = S10)
            else "001" when (currentState = S05 or currentState = S08)
            else "010" when (currentState = S06 or currentState = S09)
            else "000";
    cmd.rs_m2 <= "110" when currentState = S03
            else "111" when currentState = S04
            else "101" when (currentState = S05 or currentState = S09)
            else "001" when (currentState = S06 or currentState = S08)
            else "100" when currentState = S10
            else "010" when currentState = S11
            else "000";
    MEM <= '1' when (currentState = S06 or currentState = S09) else '0';
    done <= '1' when currentState = S12 else '0';

end behavioral;
