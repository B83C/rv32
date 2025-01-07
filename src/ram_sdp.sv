`timescale 1ns/1ps

 module ram_sdp #(
    parameter WIDTH = 32,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    // Write port - Port A
    input  logic                 clk_w,
    input  logic                 we,
    input  logic [ADDR_WIDTH-1:0] addr_w,
    input  logic [WIDTH-1:0]     data_w,
    
    // Read port - Port B
    input  logic                 clk_r,
    input  logic [ADDR_WIDTH-1:0] addr_r,
    output logic [WIDTH-1:0]     data_r
);

    (* ram_style = "block" *) logic [WIDTH-1:0] mem [DEPTH];

    // Write port
    always_ff @(posedge clk_w) begin
        if (we) begin
            mem[addr_w] <= data_w;
        end
    end

    // Read port with output register
    always_ff @(posedge clk_r) begin
        data_r <= mem[addr_r];
    end

endmodule
