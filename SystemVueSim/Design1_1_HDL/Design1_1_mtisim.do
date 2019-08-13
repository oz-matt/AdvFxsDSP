##
## Default Model Technologies simulation script
##

cd "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL"
vlib work
vmap work work

vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_source/p_fxp.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_source/Design1_1.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_source/FIR_Fxp1.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_source/FIR_Fxp1_GNRC.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/p_testbench.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/Design1_1_CE.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/Design1_1_CoSimWrapper.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/Design1_1_SimTB.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/EnableGenerator.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/FileInputProcess.vhd"
vcom -work work -93 "D:/dspws/AdvFxsDSP/SystemVueSim/Design1_1_HDL/VHDL_testbench/FileOutputProcess.vhd"

vsim -voptargs=\"+acc\" -suppress 100 work.Design1_1_SimTB

view wave

add wave -hex Design1_1_SimTB/*  

run -all

wave zoomfull

##quit -f

