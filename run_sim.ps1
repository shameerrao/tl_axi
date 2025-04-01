# PowerShell script to compile and run Icarus Verilog simulation

# Clean previous files
Write-Host "Cleaning previous files..."
Remove-Item -Recurse -Force *.o *.out *.vcd -ErrorAction SilentlyContinue

# Compile
Write-Host "Compiling design..."
iverilog -g2012 -o sim.out tlul_to_axi4.sv tlul_to_axi4_tb.sv

# Run simulation
Write-Host "Running simulation..."
vvp sim.out

# Open waveform viewer if GTKWave is installed
if (Get-Command gtkwave -ErrorAction SilentlyContinue) {
    Write-Host "Opening waveform viewer..."
    gtkwave dump.vcd
} else {
    Write-Host "GTKWave not found. Install it to view waveforms."
    Write-Host "You can install it using: choco install gtkwave"
} 