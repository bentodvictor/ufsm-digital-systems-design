-------------------------------------------------------------------------
-- Design unit: DataPath
-- Description: Bubble sort data path
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 	-- CONV_INTEGER function


entity DataPath is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
	port (  
        clk		    : in std_logic;
        rst         : in std_logic;
        startAddr   : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        size        : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        up          : in std_logic;
		
        continue    : out std_logic;
        swap        : out std_logic;
        arrayEnd    : out std_logic;
        ldAddr      : in std_logic;
        wrAddr      : in std_logic;
        addrCtrl    : in std_logic;
        dataOutCtrl : in std_logic;
        wrData0     : in std_logic;
        wrData1     : in std_logic;
        contValue   : in std_logic;
        wrContinue  : in std_logic;
        
        address	    : out std_logic_vector (ADDR_WIDTH-1 downto 0);
		dataIn 	    : in std_logic_vector (DATA_WIDTH-1 downto 0);
        dataOut     : out std_logic_vector (DATA_WIDTH-1 downto 0)
	);
end DataPath;


architecture behavioral of DataPath is

    signal inAddr0, addr0, incAddr0 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data0, data1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal comp: std_logic;
begin

    REG_ADDR0: entity work.RegisterNbits
        generic map (
            WIDTH   => ADDR_WIDTH
        )
        port map (
            clock   => clk,
            reset   => rst,
            ce      => wrAddr,
            d       => inAddr0,
            q       => addr0            
        );
        
    incAddr0 <= addr0 + 1;    
    inAddr0 <= startAddr when ldAddr = '1' else incAddr0;
    address <= incAddr0 when addrCtrl = '1' else addr0;
    arrayEnd <= '1' when (startAddr + size) = incAddr0 else '0';
    
    
    REG_DATA0: entity work.RegisterNbits
        generic map (
            WIDTH   => DATA_WIDTH
        )
        port map (
            clock   => clk,
            reset   => rst,
            ce      => wrData0,
            d       => dataIn,
            q       => data0            
        );
        
    REG_DATA1: entity work.RegisterNbits
        generic map (
            WIDTH   => DATA_WIDTH
        )
        port map (
            clock   => clk,
            reset   => rst,
            ce      => wrData1,
            d       => dataIn,
            q       => data1            
        );
        
        
    dataOut <= data1 when dataOutCtrl = '1' else data0;
    comp <= '1' when (data0 > data1 and up = '1') or (data0 < data1 and up = '0') else '0';
    swap <= comp;
    
    FF_CONTINUE: process(clk)
    begin
        if rising_edge(clk) then
            if wrContinue = '1' then
                continue <= contValue;
            end if;
        end if;
    end process;

        
end behavioral;