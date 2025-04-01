@echo off
echo Cleaning previous files...
del *.o *.out *.vcd 2>nul

echo Compiling design...
iverilog -g2012 -s tlul_to_axi4_tb -o sim.out tlul_to_axi4.sv tlul_to_axi4_tb.sv

echo Running simulation...
vvp sim.out

echo Simulation completed.
pause 