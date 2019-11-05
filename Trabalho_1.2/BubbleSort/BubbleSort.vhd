-------------------------------------------------------------------------
-- Design unit: BubbleSort
-- Description: BubbleSort top (Control path + Data path) 
--------------------------------------------------------------------------


library IEEE;						
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity BubbleSort  is
	generic(
		ADDR_WIDTH	: integer := 8;
        DATA_WIDTH  : integer := 8
	);
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
		start		: in std_logic;
        startAddr   : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        size        : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        up          : in std_logic;    
        done		: out std_logic;
        address     : out std_logic_vector (ADDR_WIDTH-1 downto 0);
        dataIn      : in std_logic_vector (DATA_WIDTH-1 downto 0);
        dataOut     : out std_logic_vector (DATA_WIDTH-1 downto 0);
        rw          : out std_logic
	);
		
end BubbleSort;

architecture structural of BubbleSort is  
        
    signal continue, swap, arrayEnd, ldAddr, wrAddr, addrCtrl, dataOutCtrl, wrData0, wrData1, contValue, wrContinue: std_logic;
    
begin


	CONTROL_PATH: entity work.ControlPath
		port map (
			clk		    => clk,
			rst		    => rst,
            start       => start,    
            done        => done,    
            rw          => rw,
            continue    => continue,   
            swap        => swap,
            arrayEnd    => arrayEnd, 
            ldAddr      => ldAddr, 
            wrAddr      => wrAddr, 
            addrCtrl    => addrCtrl, 
            dataOutCtrl => dataOutCtrl,
            wrData0     => wrData0,
            wrData1     => wrData1,  
            contValue   => contValue,
            wrContinue  => wrContinue
    );
		
	DATA_PATH: entity work.DataPath
		generic map (
			DATA_WIDTH	=> DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH
		)
		port map (
            clk         => clk,
            rst         => rst,
            startAddr   => startAddr,
            size        => size,
            continue    => continue,   
            swap        => swap,
            arrayEnd    => arrayEnd, 
            ldAddr      => ldAddr, 
            wrAddr      => wrAddr, 
            addrCtrl    => addrCtrl, 
            dataOutCtrl => dataOutCtrl,
            wrData0     => wrData0,
            wrData1     => wrData1,  
            contValue   => contValue,
            wrContinue  => wrContinue,
            dataIn      => dataIn,
            dataOut     => dataOut,
            address     => address,
            up          => up
        );
		
end structural;


architecture behavioral of BubbleSort is 

    type State is (S0, S1, S2, S3, S4, S5, S6, S7);
    signal currentState: State;
    
    signal continue, swap, arrayEnd : std_logic;
    signal addr0: std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data0, data1: std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin

    process(clk, rst)
    begin
    
        if rst = '1' then
            currentState <= S0;
            
        elsif rising_edge(clk) then
        
            case currentState is
                when S0 =>
                    continue <= '1';
                    
                    if start = '1' then
                        currentState <= S1;
                    else
                        currentState <= S0;
                    end if;
                
                when S1 =>
                    addr0 <= startAddr;
                    continue <= '0';
                                       
                    if continue = '1' then
                        currentState <= S2;
                    else
                        currentState <= S7;
                    end if;
                
                when S2 =>
                    data0 <= dataIn;
                                        
                    currentState <= S3;
            
                when S3 =>
                    data1 <= dataIn;
                    dataOut <= data0;
                                                            
                    currentState <= S4;
                
                when S4 =>
                    dataOut <= data1;
                
                    if swap = '1' then
                        currentState <= S5;
                    else
                        addr0 <= addr0 + 1;
                        currentState <= S6;
                    end if;
            
                when S5 => 
                    addr0 <= addr0 + 1;
                    dataOut <= data0;
                    continue <= '1';
                    
                    currentState <= S6;
                
                when S6 =>
                    if arrayEnd = '1' then
                        currentState <= S1;
                    else
                        currentState <= S2;
                    end if;
                
                when S7 =>                    
                    currentState <= S0;
                
                when others =>
                    currentState <= S0;
            
            end case;
        end if;
    end process;
    
   
	swap <= '1' when (data0 > data1 and up = '1') or (data0 < data1 and up = '0') else '0';
    arrayEnd <= '1' when (startAddr + size) = (addr0 + 1) else '0';
    rw <= '1' when (currentState = S4 and swap = '1') or currentState = S5 else '0'; -- Memory write
    address <= addr0 when currentState = S2 or currentState = S5 else addr0 + 1;
    done <= '1' when currentState = S7 else '0';
    
end behavioral;