# VCS Makefile for TileLink-UL to AXI4 Bridge

# VCS flags
VCS_FLAGS = -full64 -sverilog -debug_all -timescale=1ns/1ps -R

# Source files
SRCS = tlul_to_axi4.sv tlul_to_axi4_tb.sv

# Default target
all: compile run

# Compile target
compile:
	vcs $(VCS_FLAGS) $(SRCS) -o simv

# Run target
run:
	./simv

# Clean target
clean:
	rm -rf simv* csrc* *.vpd *.vcd *.log

# Waveform viewing target
wave:
	dve -vpd vcdplus.vpd

.PHONY: all compile run clean wave 