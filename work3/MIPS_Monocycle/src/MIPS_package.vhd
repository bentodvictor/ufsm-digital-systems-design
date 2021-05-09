-------------------------------------------------------------------------
-- Design unit: MIPS package
-- Description: package with...
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package MIPS_package is  
        
    -- inst_type defines the instructions decodable by the control unit
    type Instruction_type is (ADD, SUB, AAND, OOR, SW, LW, ADDI, ORI, SLT, BEQ, J, LUI, INVALID_INSTRUCTION);
 
    type Microinstruction is record
        RegWrite    : std_logic;        -- Register file write control
        ALUSrc      : std_logic;        -- Selects the ALU second operand
        RegDst      : std_logic;        -- Selects the destination register on register file
        MemToReg    : std_logic;        -- Selects the data to the register file
        wbe    		: std_logic_vector(3 downto 0);        -- Data memory write byte enable
        Branch      : std_logic;        -- Indicates the BEQ instruction
        Jump        : std_logic;        -- Indicates the J instruction
        instruction : Instruction_type; -- Decoded instruction
		ce			: std_logic;		-- Data memory enable
    end record;
         
         
end MIPS_package;


