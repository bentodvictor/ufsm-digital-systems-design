-------------------------------------------------------------------------
-- Design unit: MIPS monocycle test bench
-- Description: 
-------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MIPS_multiciclo_tb is
end MIPS_multiciclo_tb;


architecture structural of MIPS_multiciclo_tb is

    signal clock: std_logic := '0';
    signal reset, ce: std_logic;
    signal instructionAddress, dataAddress, instruction, data_i, data_o : std_logic_vector(31 downto 0);

    constant PC_START_ADDRESS : std_logic_vector(31 downto 0) := x"00400000";
    
begin

    clock <= not clock after 2 ns;
    
    reset <= '1', '0' after 2 ns;
                
        
    MIPS_MULTICICLO: entity work.MIPS_multiciclo(behavioral) 
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
			wbe        		=> "0000",	-- Read only
            address         => dataAddress(31 downto 2), -- Converts byte address to word address    
            data_o          => data_i,
			data_i			=> data_o
        );    
    
end structural;


