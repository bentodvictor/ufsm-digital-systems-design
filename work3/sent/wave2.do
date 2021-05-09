onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/clock
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/reset
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/instructionAddress
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/instruction
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/dataAddress
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/data_i
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/ce
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/PC
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/A
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/B
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/writeData
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/RegWrite
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/MUXSrcA
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/MUXSrcB
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/result
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/ALUOut
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/ext32
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/extshift
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/JAddress
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/writeReg
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/IR
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/registerFile
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/decoIR
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/cS
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/funct
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/opcode
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/rd
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/rt
add wave -noupdate /mips_multiciclo_tb/MIPS_MULTICICLO/rs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
configure wave -valuecolwidth 110
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {8338 ns} {8509 ns}
