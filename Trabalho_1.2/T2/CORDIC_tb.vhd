-------------------------------------------------------------------------
-- Design unit: BubbleSort test bench
-- Description: Tests the divider
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Test bench interface is always empty.
entity CORDIC_tb  is
end CORDIC_tb;


-- Instantiate the components and generates the stimuli.
architecture tb of CORDIC_tb is

    signal rst, start, data_av, done, done2, MEM, MEM2      : std_logic;
    signal clk                                              : std_logic := '0';
    signal data                                             : std_logic_vector(7 downto 0);
    signal i, i2                                            : std_logic_vector(7 downto 0);
    signal data_mem, data_mem2                              : std_logic_vector(31 downto 0);

begin

    -- Instantiates the units under test.
    PROCESSOR: entity work.CORDIC(structural)
        port map (
            clk         => clk,
            rst         => rst,
            start       => start,
            data_av     => data_av,
            data        => data,
            done        => done,
            MEM         => MEM,
            i           => i,
            data_mem    => data_mem
        );

    ROM: entity work.Memory
        generic map (
            DATA_WIDTH    => 32,
            ADDR_WIDTH    => 8,
            IMAGE         => "IMAGE.txt"
        )
        port map (
            clk         => clk,
            data        => data_mem,
            ce          => MEM,
            address     => i
        );

    PROCESSOR2: entity work.CORDIC(comportamental)
        port map (
            clk         => clk,
            rst         => rst,
            start       => start,
            data_av     => data_av,
            data        => data,
            done        => done2,
            MEM         => MEM2,
            i           => i2,
            data_mem    => data_mem2
        );

    ROM2: entity work.Memory
        generic map (
            DATA_WIDTH    => 32,
            ADDR_WIDTH    => 8,
            IMAGE         => "IMAGE.txt"
        )
        port map (
            clk         => clk,
            data        => data_mem2,
            ce          => MEM2,
            address     => i2
        );


    -- Generates the stimuli.
    rst <= '1', '0' after 1 ns;
    clk <= not clk after 2 ns;

    process
           begin
             start   <= '0';
             data_av <= '0';
             data    <= "00000000";
             wait until  clk = '1';
             data_av <= '1';
               wait until  clk = '1';
               data_av <= '0';
               data    <= "00100000";
               wait until  clk = '1';
                 data_av <= '1';
               wait until  clk = '1';
                 start   <= '1';
                 data_av <= '0';
                wait until clk = '1';
                 start   <= '0';
               wait;    -- Suspend process

       end process;


end tb;


