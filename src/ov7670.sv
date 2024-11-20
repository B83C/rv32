`timescale 1ns/1ps

`include "defs.svh"

module ov7670 #(
  parameter I2C_SCL_FREQ = 100_000,
  parameter I2C_CLK_FREQ = 100_000_000
)(
  input clk, plk,
  input [7:0] D,
  input vsync, hsync,
  inout sda, scl,
  input start,
  output reg xclk,
  output reg pwdn, rst,
  output camera_state sys_state
);


logic start_timer;
logic[1:0] timer_counts = 1;
logic timer_done;
timer #(.GRANULARITY(1_000_000), .COUNTS_MAX(2)) delay (.clk(clk), .start(start_timer), .counts(timer_counts), .done(timer_done));

assign pwdn = 0;


typedef struct {
  logic rst_n, start, halt, rw;
  logic [2:0] ind;
  logic [7:0] mosi;
} i2c_subsystem;

i2c_subsystem im;
i2c_state_t state;
data_state_t dstate;
wire [7:0] miso;
wire rw_done;
wire [1:0] ack;

logic rw_reg;
logic i2c_op;

i2c_m #(.SCL_FREQ(I2C_SCL_FREQ), .CLK_FREQ(I2C_CLK_FREQ)) i2c_master  (.clk(clk), .reset_n(im.rst_n), .start(im.start), .halt(im.halt), .mosi(im.mosi), .rw(im.rw), .state(state), .miso(miso), .rw_done(rw_done), .ack(ack), .sda(sda), .scl(scl));


// camera_state sys_state, ;

localparam command_cnt = 77;
logic [$clog2(command_cnt) - 1:0] command_ind = 0;

logic [15:0] command_buffer;
rom #(.WIDTH(16), .DEPTH(command_cnt), .binaryFile("ov7670_buffer.rom")) buffer_rom (.addr(command_ind), .data(command_buffer));

always_ff @(posedge clk) begin
  im.start <= 0;
  start_timer <= 0;
  rst <= 1;
  case (sys_state)
    I2C_RESET:  begin
      rst <= 0;
      if(start) begin
        im.rst_n <= 1;
        im.halt <= 0;
        sys_state <= I2C_START;
      end
    end
    I2C_START:  begin
      if(command_buffer == 16'hFFF0) begin
        start_timer <= 1;
        if (timer_done) begin
          command_ind <= command_ind + 1;
          start_timer <= 0;
        end
      end
      else if(state == IDLE) begin
        im.start <= 1;
        im.rw <= 0;
        dstate <= WRITE_DEV_ADDR;
        im.mosi <= {8'h42};
        sys_state <= SEND_COMMANDS;
      end
    end
    SEND_COMMANDS: begin
      case(dstate) 
        WRITE_DEV_ADDR:  begin
          if(rw_done) begin
            im.rw <= 0;
            im.mosi <= command_buffer[15:8];
            dstate <= WRITE_REG_ADDR;
            im.halt <= 0;
          end
        end
        WRITE_REG_ADDR:  begin
          if(rw_done) begin
            im.halt <= 0;
            im.rw <= 0;
            im.mosi <= command_buffer[7:0];
            dstate <= WRITE_REG_DATA;
          end
        end
        WRITE_REG_DATA:  begin
          if(rw_done) begin
            im.rw <= 0;
            sys_state <= I2C_START;
            im.halt <= 1;
            if(command_ind == command_cnt - 1) begin
              sys_state <= STREAM_VIDEO;
            end else begin
              command_ind <= command_ind + 1;
            end
          end
        end
        READ_REG_DATA:  begin
          sys_state <= I2C_START;
        end
      endcase
    end
    STREAM_VIDEO: begin
    end
    default: begin
      sys_state <= I2C_RESET;
      rst <= 0;
    end
  endcase
end
endmodule
