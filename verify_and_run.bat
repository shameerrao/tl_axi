@echo off
echo Current directory:
cd
echo.
echo Directory contents:
dir
echo.
echo Verilog files:
dir *.sv
echo.
echo Running Icarus Verilog...
iverilog -g2012 -s tlul_to_axi4_tb -o sim.out tlul_to_axi4.sv tlul_to_axi4_tb.sv
if errorlevel 1 goto error
echo Compilation successful
echo.
echo Running simulation...
vvp sim.out
goto end
:error
echo Compilation failed
:end
pause 