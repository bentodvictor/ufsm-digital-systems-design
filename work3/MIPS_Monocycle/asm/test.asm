# Simple instructions test

.text

start:      
    # Registers initialization 
    addi $8, $0, 1
    addi $9, $0, 9
    addi $10, $0, 10
    addi $11, $0, 11
    
    # Logic/Arithmetic test
    add $9, $10, $11
    sub $9, $11, $10    
    and $9, $10, $11
    or  $9, $10, $11
    
    # Load store test
    la  $12, array
    sw  $9, 4($12)
    lw  $2, 4($12)
    
    # Immediate Logic/Arithmetic test
    addi $9, $9, 1
    ori $9, $9, 7
    
    # Comparison test
    slt $9, $11, $12
    
    # Branch/Jump test
    beq $9, $0, start
    j start

# Unused data
.data
    size:   .word 7
    array:  .word 1 2 3 4 5 6 7
       


    
