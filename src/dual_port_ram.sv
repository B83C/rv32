`timescale 1ns/1ps

module dual_port_ram #(
    WIDTH_BITS = 64,
    BYTES = 128 * 1024,
    localparam WIDTH_BYTES = WIDTH_BITS/8,
    localparam DEPTH = BYTES/WIDTH_BYTES,
    localparam ADDR_BITS = $clog2(DEPTH)
) (
  input clka /* synthesis syn_isclock = 1 */,
  input ena,
  input [ADDR_BITS - 1:0]addra,
  output reg [WIDTH_BITS - 1:0]douta,
  input clkb /* synthesis syn_isclock = 1 */,
  input enb,
  input renb,
  input [7:0]web,
  input [ADDR_BITS - 1:0]addrb,
  input [WIDTH_BITS - 1:0]dinb,
  output logic [WIDTH_BITS - 1:0]doutb
);

    // logic [64-1:0] porta_read;
    // assign douta = porta_read[31:0];
    // Memory declaration
    (* ram_style = "block" *) logic [WIDTH_BITS-1:0] mem [DEPTH - 1:0]; // 64-bit wide memory

    // Port A (32-bit access)
    always @(posedge clka) begin
        if (ena) begin
            douta <= mem[addra];
        end    
    end
    // Port B (64-bit access)
    always @(posedge clkb) begin
        if (enb) begin
            if (web[0]) begin
                mem[addrb] <= dinb;
            end
            // for (int i = 0; i < 8; i++) begin
            //     if (web[i]) begin
            //         mem[addrb][(i*WIDTH_BYTES) +: WIDTH_BYTES] <= dinb[i * WIDTH_BYTES +: WIDTH_BYTES];
            //     end
            // end
            if (renb) begin
                doutb <= mem[addrb];
            end 
        end
    end

    integer file, r;
    initial begin
        $readmemh("/home/b83c/fpga/rv32/zig-out/bin/rv32_fpga.mem", mem);
        // file = $fopen("/home/b83c/fpga/rv32/zig-out/bin/rv32_fpga.bin", "rb");
        // r = $fread(mem, file, 0, 128 * 1024);  // Read binary data into memory
        // $fclose(file);
    end
endmodule
