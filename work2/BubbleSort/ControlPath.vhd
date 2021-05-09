-------------------------------------------------------------------------
-- Design unit: Controlpath
-- Description: Bubble sort control path 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ControlPath is
	port (  
		clk				: in std_logic;
		rst				: in std_logic;
        
        start           : in std_logic;
        done            : out std_logic;
        rw              : out std_logic;
        
        continue        : in std_logic;
        swap            : in std_logic;
        arrayEnd        : in std_logic;
        ldAddr          : out std_logic;
        wrAddr          : out std_logic;
        addrCtrl        : out std_logic;
        dataOutCtrl     : out std_logic;
        wrData0         : out std_logic;
        wrData1         : out std_logic;
        contValue       : out std_logic;
        wrContinue      : out std_logic        
	);
end ControlPath;
                   

architecture behavioral of ControlPath is  
        
    type State is (S0, S1, S2, S3, S4, S5, S6, S7);
    signal currentState, nextState : State;
    
begin
    
    -- State memory
    process(clk, rst)
    begin
        
        if rst = '1' then
            currentState <= S0;
        
        elsif rising_edge(clk) then
            currentState <= nextState;
            
        end if;
    end process;
    
    -- Next state logic
    process(currentState,swap,start,arrayEnd,continue)
    begin
        
        case currentState is
            when S0 =>
                if start = '1' then
                    nextState <= S1;
                else
                    nextState <= S0;
                end if;
                
            when S1 =>
                if continue = '1' then
                    nextState <= S2;
                else
                    nextState <= S7;
                end if;
                
            when S2 =>
                nextState <= S3;
            
            when S3 =>
                nextState <= S4;
                
            when S4 =>
                if swap = '1' then
                    nextState <= S5;
                else 
                    nextState <= S6;
                end if;
            
            when S5 => 
                nextState <= S6;
                
            when S6 =>
                if arrayEnd = '1' then
                    nextState <= S1;
                else
                    nextState <= S2;
                end if;
                
            when S7 =>
                nextState <= S0;
                
            when others =>
                nextState <= S0;
            
        end case;
        
    end process;
    
    -- Output logic
    done <= '1' when currentState = S7 else '0';
    ldAddr <= '1' when currentState = S1 else '0';
    wrAddr <= '1' when currentState = S1 or (currentState = S4 and swap = '0') or currentState = S5 else '0';
    rw <= '1' when (currentState = S4 and swap = '1') or currentState = S5 else '0'; -- Memory write (rw = 1)
    addrCtrl <= '1' when currentState = S3 or currentState = S5 else '0';
    dataOutCtrl <= '1' when currentState = S4 else '0';
    wrData0 <= '1' when currentState = S2 else '0';
    wrData1 <= '1' when currentState = S3 else '0';
    contValue <= '1' when currentState = S0 or currentState = S5 else '0';
    wrContinue <= '1' when currentState = S0 or currentState = S1 or currentState = S5 else '0';
    

    
end behavioral;
