-- MIPS MULTICICLO
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_multiciclo is
    generic (
        PC_START_ADDRESS    : integer := 0 
    );
    port ( 
        clock, reset        : in std_logic;
        
        -- Instruction memory interface
        instructionAddress  : out std_logic_vector(31 downto 0);
        instruction         : in  std_logic_vector(31 downto 0);
        
        -- Data memory interface
        dataAddress         : out std_logic_vector(31 downto 0);
        data_i              : in  std_logic_vector(31 downto 0);
		ce					: out std_logic
    );
end MIPS_multiciclo;

architecture behavioral of MIPS_multiciclo is

    signal PC					: UNSIGNED(31 downto 0);
	signal A, B, writeData		: SIGNED(31 downto 0);
	signal RegWrite				: std_logic;
	signal MUXSrcA, MUXSrcB		: SIGNED(31 downto 0);
	signal result, ALUOut		: SIGNED(31 downto 0);
	signal ext32				: std_logic_vector(31 downto 0);
	signal extshift, JAddress	: UNSIGNED(31 downto 0);
	signal writeReg				: std_logic_vector(4 downto 0);
	signal IR					: std_logic_vector(31 downto 0);
    
    -- Register file
    type RegisterArray is array (natural range <>) of SIGNED(31 downto 0);
    signal registerFile: RegisterArray(0 to 31);
    
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is IR(25 downto 21);
        
    -- Retrieves the rt field from the instruction
    alias rt: std_logic_vector(4 downto 0) is IR(20 downto 16);
        
    -- Retrieves the rd field from the instruction
    alias rd: std_logic_vector(4 downto 0) is IR(15 downto 11);
    
	-- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode	: std_logic_vector(5 downto 0) is IR(31 downto 26);
    alias  funct	: std_logic_vector(5 downto 0) is IR(5 downto 0);
    
	type Instruction_type is (ADD, SLLeft, SRAV, SUB, LW, ADDI, ORI, SLT, BEQ, J, LUI, INVALID_INSTRUCTION);
    signal decoIR: Instruction_type;
	
	-- States
	type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal cS: State;
	
begin

    -- Instruction decoding
    decoIR	<= 	ADD     when opcode = "000000" and funct = "100000" else
				SLLeft	when opcode = "000000" and funct = "000000" else
				SRAV	when opcode = "000000" and funct = "000111" else
				SUB     when opcode = "000000" and funct = "100010" else
				SLT     when opcode = "000000" and funct = "101010" else
				LW      when opcode = "100011" else
				ADDI    when opcode = "001000" else
				ORI     when opcode = "001101" else
				BEQ     when opcode = "000100" else
				J       when opcode = "000010" else
				LUI     when opcode = "001111" and rs = "00000" else
				INVALID_INSTRUCTION ;    -- Invalid or not implemented instruction
            
    assert not (decoIR = INVALID_INSTRUCTION and reset = '0')    
    report "******************* INVALID INSTRUCTION *************"
    severity error;    
    

    process(clock, reset)
    begin
    
        if reset = '1' then
            PC <= TO_UNSIGNED(PC_START_ADDRESS,32);
			
			for i in 0 to 31 loop   
                registerFile(i) <= (others=>'0');  
            end loop;
               
			cS <= S0; 
			 
        elsif rising_edge(clock) then
			case cS is
				when S0 =>		-- Busca da instrução
					IR	<= instruction;			-- IR <- MEM[PC]
					PC	<= UNSIGNED(result);	-- PC <- PC + 4
					
						cS	<= S1;
						
				when S1 =>		-- Decodificação da instrução e busca do registrador
						if decoIR = SRAV then											-- DESLOCA O CONTEUDO DE UM REG
							A		<= registerFile(TO_INTEGER(UNSIGNED(rt)));			-- A <- R[rt]
							B		<= registerFile(TO_INTEGER(UNSIGNED(rs)));			-- B <- R[rs]
						elsif decoIR = SLLeft then 										-- DESLOCA UMA CONSTANTE IMEDIATA
							A		<= registerFile(TO_INTEGER(UNSIGNED(rt)));			-- A <- R[rt]
							B		<= x"000000" & "000" & SIGNED(IR(10 downto 6));		-- B <- CONSTANTE
						else
							A		<= registerFile(TO_INTEGER(UNSIGNED(rs)));			-- A <- R[rs]
							B		<= registerFile(TO_INTEGER(UNSIGNED(rt)));			-- B <- R[rt]
						end if;
						
						ALUOut	<= result;		-- ALUOut <- PC + extshift
				
						if decoIR = LW then		-- Se instrução = LW salta pra S2
							cS	<= S2;
						elsif decoIR = BEQ then	-- Se instrução = BEQ salta pra S7
							cS	<= S7;					
						elsif decoIR = J then	-- Se instrução = JUMP salta pra S8
							cS	<= S8;
						elsif decoIR = INVALID_INSTRUCTION then	-- Se instrução inválida salta pra S9
							cS	<= S9;
						else
							cS	<= S5;
						end if;
														
				when S2 =>		-- Cálculo do endereço do dado na memória
					ALUOut <= result;		-- ALUOut <- A + ext32

						cS <= S3;
				
				when S3 =>		-- Endereçamento da memória de dados
					dataAddress	<=	STD_LOGIC_VECTOR(ALUOut);
						
						cS	<= S4;
						
				when S4 =>		-- Grava o dado lido no registrador
					if RegWrite = '1' and UNSIGNED(writeReg) /= 0 then	-- Register $0 is read-only (constant 0)
						registerFile(TO_INTEGER(UNSIGNED(writeReg))) <= SIGNED(data_i);
					end if;
					
						cS	<= S0;
					
				when S5 =>		-- Execução
					ALUOut	<= result;	
						
						cS	<= S6;
						
				when S6 =>		-- Gravação do dado no banco de registradores
					if RegWrite = '1' and UNSIGNED(writeReg) /= 0 then
						registerFile(TO_INTEGER(UNSIGNED(writeReg))) <= ALUOut;
					end if;
						
						cS	<= S0;
						
				when S7 =>		-- Branch Completion
					if (A = B) then	-- Se t9 = 0 salta para o endereço de ALUOut
						PC	<= UNSIGNED(ALUOut);
					else			-- Se t9 /= 0 segue o código
						PC	<= PC;
					end if;
					
						cS	<= S0;
						
				when S8 =>		-- Jump Completion
					PC	<= JAddress;	-- PC recebe o endereço de salto
				
						cS	<= S0;
						
				when others =>
										
			end case;
		end if;
	end process;

RegWrite	<=	'1' when cS = S4 or cS = S6 else '0';	-- Habilita a escrita no registrador

ce <= '1' when decoIR = LW else '0';					-- Habilita a memória de dados para leitura

writeReg	<= 	rd when opcode = "000000" else rt;		-- Seleciona o registrador destino de acordco com o opcode

ext32		<=	(x"FFFF" & IR(15 downto 0)) when IR(15) = '1' else	-- Se negativo extende com FFFF
				(x"0000" & IR(15 downto 0));						-- Se positivo extende com 0000

extshift	<=	UNSIGNED(ext32(29 downto 0) & "00");	-- Desloca dois bits para a esquerda

JAddress	<=	(UNSIGNED(PC(31 downto 28)) & UNSIGNED(IR(25 downto 0)) & "00");	-- Endereçamento para o Jump
				
MUXSrcA		<= 	SIGNED(PC)	when cS = S0 or decoIR = BEQ else	-- PC para PC + 4 ou para PC + ext32
				A(31 downto 16) & x"0000" when cS = S5 and decoIR = ORI else	-- Parte alta para fazer ORI com a parte baixa
				A;

MUXSrcB		<=	x"00000004" 	when cS = S0 else			-- 4 para PC + 4
				SIGNED(extshift)when cS = S1 else			-- ext32 para o BEQ
				B				when opcode = "000000" else	-- B para instruções de opcode = 0
				SIGNED(ext32);
				
result		<=  MUXSrcA - MUXSrcB 		when decoIR = SUB and cS = S5	 							else	-- SUB (-)
                MUXSrcA or  MUXSrcB		when decoIR = ORI											else 	-- ORI
                (0=>'1', others=>'0') 	when decoIR = SLT and (MUXSrcA < MUXSrcB) and cS = S5		else	-- SLT <= 1
                (others=>'0') 			when decoIR = SLT and not (MUXSrcA < MUXSrcB) and cS = S5	else	-- SLT <= 0
				MUXSrcB(15 downto 0) & x"0000" 	when decoIR = LUI and cS = S5						else	-- LUI
                (SIGNED(MUXSrcA) SLL TO_INTEGER(MUXSrcB)) when decoIR = SLLeft and cS = S5			else	-- SLL
				SIGNED(SHIFT_RIGHT(MUXSrcA, TO_INTEGER(MUXSrcB))) when decoIR = SRAV and cS = S5	else	-- SRAV
				MUXSrcA + MUXSrcB;		-- Default para BEQ[ALUOut = PC + ext32], PC e LW 

instructionAddress <= STD_LOGIC_VECTOR(PC);	-- Endereçamento da memória de instruções
				
end behavioral;