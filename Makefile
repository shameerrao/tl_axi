# VCS simulation Makefile

# Compiler and flags
VCS = vcs
VCS_FLAGS = -full64 +v2k -timescale=1ns/1ps -debug_pp +vcd

# Source files
SRCS = tlul_to_axi4.v tlul_to_axi4_tb.v

# Simulation executable
SIMV = simv

# VCD file
VCD_FILE = tlul_to_axi4.vcd

# Default target
all: sim

# Compile and run simulation
sim: $(SRCS)
	$(VCS) $(VCS_FLAGS) $(SRCS)
	./$(SIMV)

# View waveform
wave: $(VCD_FILE)
	gtkwave $(VCD_FILE)

# Clean generated files
clean:
	rm -rf $(SIMV) $(VCD_FILE) csrc simv.daidir ucli.key DVEfiles

# Clean and rebuild
rebuild: clean sim

# Help
help:
	@echo "Available targets:"
	@echo "  all    - Build everything (default)"
	@echo "  sim    - Compile and run simulation"
	@echo "  wave   - View waveform in GTKWave"
	@echo "  clean  - Remove generated files"
	@echo "  rebuild- Clean and rebuild"
	@echo "  help   - Show this help message"

.PHONY: all sim wave clean rebuild help 