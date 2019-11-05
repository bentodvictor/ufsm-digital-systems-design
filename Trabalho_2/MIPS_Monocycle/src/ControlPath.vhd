-------------------------------------------------------------------------
-- Design unit: Control path
-- Description: MIPS control path supporting ADD, SUB, AND, OR, LW, SW, ADDI, ORI, SLT, BEQ, J, LUI instructions.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_package.all;


entity ControlPath is
    port (  
        clock           : in std_logic;
        reset           : in std_logic;
        instruction     : in std_logic_vector(31 downto 0);
        uins            : out microinstruction
    );
end ControlPath;
                   

architecture behavioral of ControlPath is

    -- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode: std_logic_vector(5 downto 0) is instruction(31 downto 26);
    alias  funct: std_logic_vector(5 downto 0) is instruction(5 downto 0);
    
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is instruction(25 downto 21);
    
    signal decodedInstruction: Instruction_type;
    
begin

    uins.instruction <= decodedInstruction;     -- Used to set the ALU operation
    
    -- Instruction decode
    decodedInstruction <=   ADD     when opcode = "000000" and funct = "100000" else
                            SUB     when opcode = "000000" and funct = "100010" else
                            AAND    when opcode = "000000" and funct = "100100" else
                            OOR     when opcode = "000000" and funct = "100101" else
                            SLT     when opcode = "000000" and funct = "101010" else
                            SW      when opcode = "101011" else
                            LW      when opcode = "100011" else
                            ADDI    when opcode = "001000" else
                            ORI     when opcode = "001101" else
                            BEQ     when opcode = "000100" else
                            J       when opcode = "000010" else
                            LUI     when opcode = "001111" and rs = "00000" else
                            INVALID_INSTRUCTION ;    -- Invalid or not implemented instruction
            
    assert not (decodedInstruction = INVALID_INSTRUCTION and reset = '0')    
    report "******************* INVALID INSTRUCTION *************"
    severity error;    


    -- R-type instructions, ADDI, ORI, LUI and LW store the result in the register file
    uins.RegWrite <= '1' when opcode = "000000" or decodedInstruction = LW or decodedInstruction = ADDI or decodedInstruction = ORI or decodedInstruction = LUI else '0';
    
    -- In R-type instructions, LUI or BEQ, the second ALU operand comes from the register file
    uins.ALUSrc <= '0' when opcode = "000000" or decodedInstruction = BEQ else '1';
    
    -- Memory set to write words
	uins.wbe <= "1111" when decodedInstruction = SW else (others=>'0');
	
	-- Memory enabled only on load/store instructions
	uins.ce <= '1' when decodedInstruction = LW or decodedInstruction = SW else '0';
    
    -- In load instructions the data comes from the data memory
    uins.MemToReg <= '1' when decodedInstruction = LW else '0';
    
    -- In r-type instructions the destination register is in the 'rd' field
    uins.RegDst <= '1' when opcode = "000000" else '0';
    
    -- Indicates the BEQ instruction
    uins.Branch <= '1'when decodedInstruction = BEQ else '0';
    
    -- Indicates the J instruction
    uins.Jump <= '1' when decodedInstruction = J else '0';
    
end behavioral;
