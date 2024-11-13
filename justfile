vivado := "/home/b83c/tools/Xilinx/Vivado/2024.1/bin/vivado"

sim:
    mkdir -p sim
    @echo "Compiling Verilog file..."
    cd sim; verilator --binary -j 16  --build tb.sv --trace -I../src/ -I../src/tb/ --timing
    @echo "Running simulation..."
    cd sim; ./obj_dir/Vtb
    @echo "Simulation complete. Run 'just wave' to view the waveform."

wave: sim
    @echo "Opening GTKWave..."
    cd sim; gtkwave waveform.vcd

build:
     {{ vivado }} -nolog -nojournal -mode batch -source  build.tcl 

cmd:
     {{ vivado }} -nolog -nojournal -mode tcl -source  init.tcl 

update_ip:
     {{ vivado }} -nolog -nojournal -mode tcl -source  update_ip.tcl 

# /home/b83c/tools/Xilinx/Vivado/2024.1/bin/vivado -nolog -nojournal -mode batch -notrace -quiet -source  build.tcl 

upload: 
    openFPGALoader -b basys3 ./target/BASYS3.bit
    
