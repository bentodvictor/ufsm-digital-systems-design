# TCL ModelSim compile script
# Pay atention on the compilation order!!! (Botton up)



# Sets the compiler
#set compiler vlog
set compiler vcom


# Creats the work library if it does not exist
if { ![file exist work] } {
	vlib work
	vmap work work
}




#########################
### Source files list ###
#########################

# Source files listed in hierarchical order: botton -> top
set sourceFiles {
	Util_package.vhd
    Memory.vhd
    RegisterNbits.vhd
    DataPath.vhd
    ControlPath.vhd
    BubbleSort.vhd
    BubbleSort_tb.vhd
}



set testBench BubbleSort_tb	



###################
### Compilation ###
###################

if { [llength $sourceFiles] > 0 } {
	
	foreach file $sourceFiles {
		if [ catch {$compiler $file} ] {
			puts "\n*** ERROR compiling file $file :( ***" 
			return;
		}
	}
}




################################
### Lists the compiled files ###
################################

if { [llength $sourceFiles] > 0 } {
	
	puts "\n*** Compiled files:"  
	
	foreach file $sourceFiles {
		puts \t$file
	}
}


puts "\n*** Compilation OK ;) ***"


