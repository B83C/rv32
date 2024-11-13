`timescale 1ns/1ps
module ov7670#(
  parameter I2C_SCL_FREQ = 100_000,
  parameter I2C_CLK_FREQ = 100_000_000
)(
  input clk, plk,
  input [7:0] D,
  input vsync, hsync,
  inout sda, scl,
  input start,
  output reg xclk,
  output reg pwdn, rst
);

typedef struct {
  logic rst_n, start, halt, rw, rw_stop;
  logic [2:0]ind;
  logic mosi;
} i2c_subsystem;


`include "defs.svh"

// import defs::*;


i2c_subsystem im;
state_t state;
data_state_t dstate;
wire miso, rw_done;
wire [1:0] ack;
reg [7:0] buffers [3:0];

logic rw_reg;
logic i2c_op;

i2c_m #(.SCL_FREQ(I2C_SCL_FREQ), .CLK_FREQ(I2C_CLK_FREQ)) i2c_master  (.clk(clk), .reset_n(im.rst_n), .start(im.start), .halt(im.halt), .mosi(im.mosi), .rw(im.rw), .rw_stop(im.rw_stop), .state(state), .miso(miso), .rw_done(rw_done), .ack(ack), .sda(sda), .scl(scl));

always_ff @(posedge clk) begin
  case(state) inside
    START: begin
      im.halt <= 0;
      im.rw_stop <= 0;
      dstate <= WRITE_DEV_ADDR;
      im.ind <= 7;
      im.rw <= 0;
      case(dstate) 
        READ_REG_DATA: begin
          buffers[WRITE_DEV_ADDR][0] <= 1; // Read
        end
        default : begin
          buffers[WRITE_DEV_ADDR][0] <= 0; // Write
        end
      endcase
    end
    WRITE: begin
      // im.mosi <= im.ind == 0? 1'b1: buffers[dstate][im.ind];
      im.mosi <= buffers[dstate][im.ind]; //C
      if(rw_done) begin //D
        if(im.ind == 0) begin
          im.rw_stop <= 1;
        end else begin
          im.ind <= im.ind - 1;
        end
      end
    end
    CHECK_ACK: begin
      if(im.ind == 0) begin
        case(dstate) 
          WRITE_DEV_ADDR: begin
            im.rw_stop <= 0;
            if (buffers[WRITE_DEV_ADDR][0]) begin
              dstate <= READ_REG_DATA;
              im.ind <= 7;
              im.rw <= 1; //Really start reading
            end else begin
              dstate <= WRITE_REG_ADDR;
              im.ind <= 7;
              im.rw <= 0;
            end
          end
          WRITE_REG_DATA: begin
            im.rw_stop <= 0;
            im.ind <= 7;
            if (!i2c_op) begin //check if write should continue
              im.halt <= 1;
            end
          end
          WRITE_REG_ADDR: begin
            im.rw_stop <= 0;
            im.ind <= 7;
            if (rw_reg) begin
              im.halt <= 1; //Restart to read register data
              dstate <= READ_REG_DATA;
            end else begin
              dstate <= WRITE_REG_DATA;
            end
          end
          default: begin
            im.halt <= 1;
          end
        endcase
      	
      end
    end
    READ: begin
      if(rw_done) begin
        buffers[dstate][im.ind - 1] <= miso;
        if(im.ind == 0) begin
          im.rw_stop <= 1;
          if (!i2c_op) begin
            im.halt <= 1;
            dstate <= WRITE_DEV_ADDR;
          end
        end else begin
          im.ind <= im.ind - 1;
        end
      end
    end
    default: begin
      // im.halt <= 1;
      // i2c_op <= 0;
    end
  endcase
end


typedef enum {
  I2C_RESET,
  I2C_START,
  SEND_COMMANDS,
  STREAM_VIDEO
} camera_state;

camera_state sys_state;

localparam command_cnt = 16;
logic [15:0] command_buffers [command_cnt - 1:0] = {
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32,
  16'hff32
};

logic [$clog2(command_cnt) - 1:0] command_ind = 0;
always_ff @(posedge clk) begin
  case (sys_state)
    I2C_RESET:  begin
      if(start) begin
        im.rst_n <= 1;
        sys_state <= I2C_START;
      end
    end
    I2C_START:  begin
      im.start <= 1;
      buffers[WRITE_DEV_ADDR] <= {7'h42, 1'b0};
      rw_reg <= 0;
      // if(rw_done) begin
        sys_state <= SEND_COMMANDS;
      // end
    end
    SEND_COMMANDS: begin
      buffers[WRITE_REG_ADDR] <= command_buffers[command_ind][15:8];
      buffers[WRITE_REG_DATA] <= command_buffers[command_ind][7:0];
      if(rw_done && dstate == WRITE_REG_DATA) begin
        i2c_op <= 0;
        if(command_ind == command_cnt[$clog2(command_cnt) - 1:0] - 1) begin
          i2c_op <= 0;
          sys_state <= STREAM_VIDEO;
        end else begin
          command_ind <= command_ind + 1;
        end
      end else begin
        i2c_op <= 1;
      end
    end
    STREAM_VIDEO: begin
    end
    default: begin
      sys_state <= I2C_RESET;
    end
  endcase
end
endmodule
