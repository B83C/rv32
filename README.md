# A simple RV32I processor made from scratch in SystemVerilog/Verilog

TBA

# Prerequisite 
- **Vivado**. Change the vivado variable in *justfile* to point to the path of your vivado program. If vivado is already in your path (i.e. You can launch it directly from terminal/cmd by just 'vivado'), then leave it as 'vivado'.
- (Optional) **Verilator**. Verilator is used in this project in place of vivado to speed up simulation (and also because it's foss)

# Setup
Run `just build` to build the entire project

# Simulation
Run `just sim [wave]` to simulate the project, and display the waveform using gtkwave (if specified).
