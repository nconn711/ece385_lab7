onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Clk /testbench/CLK
add wave -noupdate -label Reset /testbench/RESET
add wave -noupdate -label Start /testbench/AES_START
add wave -noupdate -label Done /testbench/AES_DONE
add wave -noupdate -label KEY -radix hexadecimal /testbench/AES_KEY
add wave -noupdate -label MSG_ENC -radix hexadecimal /testbench/AES_MSG_ENC
add wave -noupdate -label MSG_DEC -radix hexadecimal /testbench/AES_MSG_DEC
add wave -noupdate -label state /testbench/top/sm_0/state
add wave -noupdate -label Round -radix unsigned /testbench/top/sm_0/Round
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {807330 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
configure wave -valuecolwidth 201
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {2958350 ps} {3890759 ps}
