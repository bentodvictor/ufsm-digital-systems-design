-------------------------------------------------------------------------
-- Design unit: MIPS monocycle test bench
-- Description: 
-------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_package.all;


entity MIPS_monocycle_tb is
end MIPS_monocycle_tb;


architecture structural of MIPS_monocycle_tb is

    signal clock: std_logic := '0';
    signal reset, ce: std_logic;
	signal wbe: std_logic_vector(3 downto 0);
    signal instructionAddress, dataAddress, instruction, data_i, data_o : std_logic_vector(31 downto 0);

    constant PC_START_ADDRESS : std_logic_vector(31 downto 0) := x"00400000";
    
begin

    clock <= not clock after 5 ns;
    
    reset <= '1', '0' after 7 ns;
                
        
    MIPS_MONOCYCLE: entity work.MIPS_monocycle(behavioral) 
        generic map (
            PC_START_ADDRESS => TO_INTEGER(UNSIGNED(PC_START_ADDRESS))
        )
        port map (
            clock               => clock,
            reset               => reset,
            
            -- Instruction memory interface
            instructionAddress  => instructionAddress,    
            instruction         => instruction,        
                 
             -- Data memory interface
            dataAddress         => dataAddress,
            data_i              => data_i,
            data_o              => data_o,
            wbe            		=> wbe,
			ce					=> ce
        );
    
    
    INSTRUCTION_MEMORY: entity work.Memory(behavioral)
        generic map (
            SIZE            => 100,                 -- Memory depth
            START_ADDRESS   => PC_START_ADDRESS,    -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "test_code.txt"
        )
        port map (
            clock           => clock,
            ce				=> '1', -- Memory read at each cycle
			wbe        		=> "0000",	-- Only Read (ROM)
            address         => instructionAddress(31 downto 2), -- Converts byte address to word address    
            data_i          => data_o,
            data_o          => instruction
        );
        	
	DATA_MEMORY: entity work.Memory(behavioral)
        generic map (
            SIZE            => 100,             -- Memory depth
            START_ADDRESS   => x"10010000",     -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "test_data.txt"
        )
        port map (
            clock           => clock,
            ce				=> ce,
			wbe        		=> wbe,
            address         => dataAddress(31 downto 2), -- Converts byte address to word address    
            data_i          => data_o,
            data_o          => data_i
        );    
    
end structural;


