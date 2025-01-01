`timescale 1ns/1ps

module dual_port_ram #(
) (
  input clka /* synthesis syn_isclock = 1 */,
  input ena,
  input [13:0]addra,
  output reg [63:0]douta,
  output logic readya,
  input clkb /* synthesis syn_isclock = 1 */,
  input enb,
  input renb,
  input [7:0]web,
  input [13:0]addrb,
  input [63:0]dinb,
  output reg [63:0]doutb
);

    // logic [64-1:0] porta_read;
    // assign douta = porta_read[31:0];
    // Memory declaration
    (* ram_style = "block" *) logic [64-1:0] mem [128 * 1024/ 8 - 1:0]; // 64-bit wide memory

    // Port A (32-bit access)
    always @(posedge clka) begin
        readya <= 0;
        if (ena) begin
            douta  <= mem[addra];
            readya <= 1;
        end
    end
    // Port B (64-bit access)
    always @(posedge clkb) begin
        if (enb) begin
            for (int i = 0; i < 8; i++) begin
                if (web[i]) begin
                    mem[addrb][(i*8) +: 8] <= dinb[i * 8 +: 8];
                end
            end
            // if (renb) begin
            doutb <= mem[addrb];
            // end 
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
