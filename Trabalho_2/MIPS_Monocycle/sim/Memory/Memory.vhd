-------------------------------------------------------------------------
-- Design unit: Memory
-- Description: 32 bits word memory
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use std.textio.all;
use work.Util_pkg.all;


entity Memory is
    generic (
        SIZE            : integer := 100;    -- Memory depth
        START_ADDRESS   : std_logic_vector(31 downto 0) := (others=>'0');    -- Address to be mapped to address 0x00000000
        imageFileName   : string := "UNUSED"    -- Memory content to be loaded
    );
    port (  
        clock           : in std_logic;
        ce              : in std_logic; -- Enable the memory
        wbe             : in std_logic_vector(3 downto 0);  -- Write byte enable: indicates which byte(s) contained on data_i should be written
        address         : in std_logic_vector (29 downto 0);
        data_i          : in std_logic_vector (31 downto 0);
        data_o          : out std_logic_vector (31 downto 0)
    );
end Memory;


architecture behavioral of Memory is

    -- Word addressed memory
    type Memory is array (0 to SIZE) of std_logic_vector(31 downto 0);
    signal memoryArray: Memory;
           
    ----------------------------------------------------------------------------
    -- This procedure loads the memory array with the specified file in 
    -- the following format
    --
    --
    --      Address    Code        Basic                  Source
    --
    --    0x00400000  0x014b4820  add $9,$10,$11    4  add $t1, $t2, $t3
    --    0x00400004  0x016a4822  sub $9,$11,$10    5  sub $t1, $t3, $t2    
    --    0x00400008  0x014b4824  and $9,$10,$11    6  and $t1, $t2, $t3
    --    0x0040000c  0x014b4825  or $9,$10,$11     7  or  $t1, $t2, $t3
    --    ...
    ----------------------------------------------------------------------------
    function MemoryLoad(imageFileName: in string) return Memory is
        
        file imageFile          : TEXT open READ_MODE is imageFileName;
        variable memoryArray    : Memory;
        variable fileLine       : line;                -- Stores a read line from a text file
        variable str            : string(1 to 8);    -- Stores an 8 characters string
        variable char           : character;        -- Stores a single character
        variable bool           : boolean;            -- 
        variable address, data: std_logic_vector(31 downto 0);
                
        begin
        
            while NOT (endfile(imageFile)) loop    -- Main loop to read the file
                
                -- Read a file line into 'fileLine'
                readline(imageFile, fileLine);    
                
                -- Verifies if the line contains address and code.
                -- Such lines start with "0x"
                if fileLine'length > 2 and fileLine(1 to 2) = "0x" then
                
                    -- Read '0' and 'x'
                    read(fileLine, char, bool);
                    read(fileLine, char, bool);
                    
                    -- Read the address character by character and stores in 'str'
                    for i in 1 to 8 loop
                        read(fileLine, char, bool);
                        str(i) := char;
                    end loop;
                    
                    
                    -- Converts the string address 'str' to std_logic_vector
                    address := StringToStdLogicVector(str);
                    
                    -- Sets the real address
                    address := STD_LOGIC_VECTOR(UNSIGNED(address) - UNSIGNED(START_ADDRESS));
                    
                                    
                    -- Read the 2 blanks between address and code
                    read(fileLine, char, bool);
                    read(fileLine, char, bool);
                    
                    
                    -- Read '0' and 'x'
                    read(fileLine, char, bool);
                    read(fileLine, char, bool);
                    
                    -- Read the code/data character by character and stores in 'str'
                    for i in 1 to 8 loop
                        read(fileLine, char, bool);
                        str(i) := char;
                    end loop;
                    
                    -- Converts the string code/data 'str' to std_logic_vector
                    data := StringToStdLogicVector(str);
                    
                    -- Converts the byte address to word address
                    address := "00" & address(31 downto 2);
                    
                    -- Stores the 'data' into the memoryArray
                    memoryArray(TO_INTEGER(UNSIGNED(address))) := data;
                    
                end if;
            end loop;
            
            return memoryArray;
            
    end MemoryLoad;
    
    -- Address bus input is mapped to the memory begin according to the START_ADDRESS parameter
    signal mappedAddress: std_logic_vector(29 downto 0);

begin
        
    mappedAddress <= STD_LOGIC_VECTOR(UNSIGNED(address) - UNSIGNED(START_ADDRESS(31 downto 2)));    -- Converts START_ADDRESS to word address
    
    -----------------        
    -- Memory read --
    -----------------
    MEMORY_READ: data_o <= memoryArray(TO_INTEGER(UNSIGNED(mappedAddress))) when ce = '1' and UNSIGNED(mappedAddress) < SIZE else (others=>'U');

    ----------------------------------------------------------------------
    -- Memory write                                                     --
    --  Process to load the memory array and control the memory writing --
    ----------------------------------------------------------------------
    MEMORY_WRITE: process(clock)
        variable memoryLoaded: boolean := false;    -- Indicates if the memory was already loaded
    begin        
        
        -- Memory load from image file
        if not memoryLoaded then
            if imageFileName /= "UNUSED" then                
                memoryArray <= MemoryLoad(imageFileName);
            end if;
             
             memoryLoaded := true;
        end if;
        
        -- Memory write
        if rising_edge(clock) then    -- Memory writing        
            if ce = '1' and wbe /= "0000" then
                if UNSIGNED(mappedAddress) < SIZE then
                    case wbe is
                    
                        ------------------
                        -- Byte storing --
                        ------------------
                        when "0001" =>  -- Store byte 0
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(7 downto 0) <= data_i(7 downto 0);
                            
                        when "0010" =>  -- Store byte 1
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(15 downto 8) <= data_i(15 downto 8);
                        
                        when "0100" =>  -- Store byte 2
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(23 downto 16) <= data_i(23 downto 16);
                        
                        when "1000" =>  -- Store byte 3
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(31 downto 24) <= data_i(31 downto 24);
                            
                        -----------------------
                        -- Half word storing --
                        -----------------------
                        when "0011" =>  -- Store half word 0
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(15 downto 0) <= data_i(15 downto 0);
                            
                        when "1100" =>  -- Store half word 1
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress)))(31 downto 16) <= data_i(31 downto 16);
                        
                        -----------------------
                        -- Word storing --
                        -----------------------
                        when "1111" =>  -- Store word
                            memoryArray(TO_INTEGER(UNSIGNED(mappedAddress))) <= data_i;
                        
                        when others =>
                            report "******************* INVALID WRITE BYTE ENABLE *******************"
                            severity failure;
                            
                    end case;
                
                else
                    report "******************* MEMORY WRITE OUT OF BOUNDS *******************";
                end if;
            end if;
        end if;
        
    end process;
        
end behavioral;