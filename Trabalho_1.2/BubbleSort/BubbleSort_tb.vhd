-------------------------------------------------------------------------
-- Design unit: BubbleSort test bench
-- Description: Tests the divider
-------------------------------------------------------------------------

library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Test bench interface is always empty.
entity BubbleSort_tb  is
end BubbleSort_tb;


-- Instantiate the components and generates the stimuli.
architecture behavioral of BubbleSort_tb is  
    
    constant DATA_WIDTH     : integer := 12;
    constant ADDR_WIDTH     : integer := 12;
    
    signal rst, start       : std_logic; 
    signal size, startAddr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal clk              : std_logic := '0';
    signal rw               : std_logic;
    signal up               : std_logic;
    signal done             : std_logic;
    signal address          : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data, dataOut    : std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin

    -- Instantiates the units under test.
    PROCESSOR: entity work.BubbleSort(structural) 
        generic map (
            DATA_WIDTH    => DATA_WIDTH,
            ADDR_WIDTH    => ADDR_WIDTH
        )
        port map (
            clk         => clk,
            rst         => rst,
            start       => start,
            done        => done,
            startAddr   => startAddr,
            size        => size,
            up          => up,
            rw          => rw,
            dataIn      => data,
            dataOut     => dataOut,
            address     => address
        );
        
    RAM: entity work.Memory
        generic map (
            DATA_WIDTH    => DATA_WIDTH,
            ADDR_WIDTH    => ADDR_WIDTH,
            IMAGE         => "image3.txt"
        )
        port map (
            clk         => clk,
            rw          => rw,
            data        => data,
            ce          => '1',
            address     => address
        );
        
    -- Generates the stimuli.
    rst <= '0', '1' after 10 ns, '0' after 15 ns;
    clk <= not clk after 20 ns;    -- 25 MHz
    data <= dataOut when rw = '1' else (others=>'Z');
    
    process
           begin
               start <= '0';
            up <= '1';
               
               wait until  clk = '1';
               wait until  clk = '1';
               start<= '1';
               startAddr <= STD_LOGIC_VECTOR(TO_UNSIGNED(0,ADDR_WIDTH));
               size <= STD_LOGIC_VECTOR(TO_UNSIGNED(11,ADDR_WIDTH));
               
               wait until clk = '1';
               start <= '0';
            
            wait until done = '1';
            wait until done = '0';
            up <= '0';
            start<= '1';
            
            wait until clk = '1';
            start <= '0';
            
               wait;    -- Suspend process          
               
       end process;
       

end behavioral;


