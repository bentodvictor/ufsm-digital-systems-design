onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider BubbleSort
add wave -noupdate -format Logic -radix hexadecimal /bubblesort_tb/processor/clk
add wave -noupdate -format Logic -radix hexadecimal /bubblesort_tb/processor/rst
add wave -noupdate -format Logic -radix hexadecimal /bubblesort_tb/processor/start
add wave -noupdate -format Literal -radix hexadecimal /bubblesort_tb/processor/startaddr
add wave -noupdate -format Literal -radix hexadecimal /bubblesort_tb/processor/size
add wave -noupdate -format Logic -radix hexadecimal /bubblesort_tb/processor/up
add wave -noupdate -format Logic -radix hexadecimal /bubblesort_tb/processor/done
add wave -noupdate -divider Memory
add wave -noupdate -format Literal -radix hexadecimal -expand /bubblesort_tb/ram/memoryarray
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29900 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {27849 ns} {31951 ns}
