transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/state_machine.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/InvAddKey.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/SubBytes.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/InvShiftRows.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/InvMixColumns.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/KeyExpansion.sv}
vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1 {C:/Users/STP/Desktop/ece385_lab7/Lab7_Avalon_Provided_2.1/AES.sv}
vlib lab7_soc
vmap lab7_soc lab7_soc

vlog -sv -work work +incdir+C:/Users/STP/Desktop/ece385_lab7 {C:/Users/STP/Desktop/ece385_lab7/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -L lab7_soc -voptargs="+acc"  testbench

do C:/Users/STP/Desktop/ece385_lab7/simulation/modelsim/wave_0.do
