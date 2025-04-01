@echo off
echo Compiling design...
iverilog -g2012 -s tlul_to_axi4_tb -o sim.out tlul_to_axi4.sv tlul_to_axi4_tb.sv
if errorlevel 1 goto error
echo Compilation successful
goto end
:error
echo Compilation failed
:end
pause 