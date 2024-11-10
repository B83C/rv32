`timescale 1ns/1ps

module i2c_master #(
  parameter DATA_WIDTH = 8, 
  parameter REGISTER_ADDR_WIDTH = 8,
  parameter ADDRESS_WIDTH = 7
) (
  input clk,
  input reset_n,
  input en,
  input rw,
  input [DATA_WIDTH-1: 0] mosi,
  input [REGISTER_ADDR_WIDTH-1: 0] register_addr,
  input [ADDRESS_WIDTH - 1: 0] device_addr,
  input [15:0] divider,

  output reg [DATA_WIDTH-1: 0] miso,
  output reg busy,

  inout sda,
  inout scl
);

typedef enum
{
  S_IDLE,
  S_START,
  S_WRITE_ADDR,
  S_CHECK_ACK,
  S_WRITE_REGISTER_ADDR,
  S_WRITE_REG_DATA,
  S_READ_REG_DATA,
  S_RESTART,
  S_SEND_ACK,
  S_STOP
} state_type;

typedef struct {
  reg [ADDRESS_WIDTH:0] device_addr;
  reg [REGISTER_ADDR_WIDTH-1:0] reg_addr;
  reg [DATA_WIDTH-1:0] mosi;
  reg [DATA_WIDTH-1:0] miso;
  reg rw;
} saved_data;

typedef struct {
  state_type state_stack [2:0];
  reg serial_clk;
  reg serial_data_stack [2:0];
  reg last_ack;

  reg [1:0] process_counter;
  reg [4:0] bit_cnt;

  reg [15:0] divider_counter;

  reg busy;
} system_state;

saved_data sd;
system_state ss;
system_state next_ss;

reg output_data_en;
reg output_clk_en;
assign sda = output_data_en? ss.serial_data_stack[0]: 1'bz;
assign scl = output_clk_en? ss.serial_clk: 1'bz;
assign busy = ss.busy;
assign miso = sd.miso;

always_comb begin
  next_ss = ss;
  if (ss.divider_counter == divider) begin
    next_ss.divider_counter = 0;
    case (ss.state_stack[0]) 
      S_IDLE: begin
        if(en) begin
          sd.mosi = mosi;
          sd.device_addr = {device_addr, 1'b0};
          sd.reg_addr = register_addr;
          sd.rw = rw;
          next_ss.busy = 1;
          next_ss.state_stack[0] = S_START;
          next_ss.state_stack[1] = S_WRITE_ADDR;
          next_ss.state_stack[2] = S_WRITE_REGISTER_ADDR;
          next_ss.serial_data_stack[0] = 1;
          next_ss.serial_data_stack[2] = sd.reg_addr[REGISTER_ADDR_WIDTH - 1];
          next_ss.bit_cnt = 8;
        end
      end
      S_START: begin
        case (ss.process_counter) 
          0: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            next_ss.serial_data_stack[0] = 0;
            next_ss.process_counter = 2;
          end
          2: begin
              next_ss.process_counter = 3;
          end
          3: begin
            next_ss.serial_clk = 0;
            next_ss.process_counter = 0;
            next_ss.state_stack[0] = ss.state_stack[1];
            next_ss.serial_data_stack[0] = sd.device_addr[ADDRESS_WIDTH];
            //Write device address with w bit set on start
            next_ss.state_stack[1] = ss.state_stack[2];
            next_ss.serial_data_stack[1] = ss.serial_data_stack[2];
          end
        endcase
        // next_ss.serial_clk = ~ss.process_counter[1];
        // next_ss.process_counter = ss.process_counter + {1'b0, (ss.process_counter == 1) & scl}; //Allow for clock stretching
        // next_ss.serial_data_stack[0] = 
      end
      S_WRITE_ADDR: begin
        case (ss.process_counter)
          0: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if (scl) begin //Clock stretching
              next_ss.last_ack = 0;
            	next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_clk = 0;
            next_ss.bit_cnt = ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if(ss.bit_cnt == 0) begin
              next_ss.state_stack[0] = S_CHECK_ACK;
              // next_ss.serial_data_stack[0] = 0; //rw bit! W is active low, not sure about that ...
              //Hack!
              if (ss.state_stack[1] == S_READ_REG_DATA) begin
                next_ss.bit_cnt = DATA_WIDTH;
              end else begin
                next_ss.bit_cnt = REGISTER_ADDR_WIDTH;
              end
            end
            else begin
              next_ss.serial_data_stack[0] = sd.device_addr[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      S_CHECK_ACK: begin
        case (ss.process_counter) 
          0: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if (scl) begin //Clock stretching
              // next_ss.
              next_ss.last_ack = 0;
            	next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_clk = 0;
            if (sda == 0) begin
              next_ss.last_ack = 1;
            end          
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.last_ack)  begin
              next_ss.state_stack[0] = ss.state_stack[1];
              next_ss.serial_data_stack[0] = ss.serial_data_stack[1];
              next_ss.last_ack = 0;
            end else begin
              next_ss.state_stack[0] = S_STOP;
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      S_WRITE_REGISTER_ADDR: begin
        case (ss.process_counter) 
          0: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if (scl) begin //Check for clock stretching
            	next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_clk = 0;
            next_ss.bit_cnt = next_ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.state_stack[0] = S_CHECK_ACK;
              if (ss.bit_cnt[3]) begin //16 bit case
                next_ss.state_stack[1] = S_WRITE_REGISTER_ADDR;
                next_ss.serial_data_stack[1] = sd.reg_addr[ss.bit_cnt - 1];
              end else begin
                if (sd.rw) begin
                  next_ss.state_stack[1] = S_RESTART; //Reading requires restarting the process
                  next_ss.serial_data_stack[1] = 1;
                end else begin
                  next_ss.state_stack[1] = S_WRITE_REG_DATA;
                  next_ss.serial_data_stack[1] = sd.mosi[DATA_WIDTH - 1];
                end
              end
            end else begin
              next_ss.serial_data_stack[0] = sd.reg_addr[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      //*REQUIREMENT* Assuming that before entering restart that serial data has been set to high 
      S_RESTART: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
          end
          1: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 3;
          end
          2: begin
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.state_stack[0] = S_START;
            next_ss.state_stack[1] = S_WRITE_ADDR;
            next_ss.state_stack[2] = S_READ_REG_DATA;
            next_ss.serial_data_stack[2] = 0;
            sd.device_addr[0] = 1;
            // next_ss.serial_data_stack[1] = 1; //TODO
            next_ss.process_counter = 0;
          end
        endcase
      end
      S_READ_REG_DATA: begin
        case(ss.process_counter)
          0: begin
            next_ss.process_counter = 1;
            next_ss.serial_clk = 1;
          end
          1: begin
            //clock stretching
            if(scl) begin
              next_ss.process_counter = 2;
            end
          end
          2: begin
            sd.miso[ss.bit_cnt - 1] = sda;
            next_ss.process_counter = 3;
            next_ss.bit_cnt = ss.bit_cnt - 1;
            next_ss.serial_clk = 0; 
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.serial_data_stack[0] = 0;
                next_ss.state_stack[0] = S_SEND_ACK;
              if (ss.bit_cnt[3]) begin
                next_ss.serial_data_stack[1] = 0; //Ack
                // next_ss.serial_data_stack[2] = 0; //Ack follow previous data state
                next_ss.state_stack[1] = S_READ_REG_DATA;
              end else begin
                next_ss.serial_data_stack[1] = 1; //Nack
                // next_ss.serial_data_stack[2] = 0; //Nack idk why 
                next_ss.state_stack[1] = S_STOP;
              end
            end else begin
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      S_WRITE_REG_DATA: begin
        case(ss.process_counter)
          0: begin
            next_ss.serial_clk = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if(scl) begin
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_clk = 0;
            next_ss.bit_cnt = ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.state_stack[0] = S_CHECK_ACK;
              if (ss.bit_cnt[3]) begin //16 bit case
                next_ss.state_stack[1] = S_WRITE_REG_DATA;
                next_ss.serial_data_stack[1] = sd.mosi[ss.bit_cnt - 1];
              end else begin
                next_ss.state_stack[1] = S_STOP;
              end
            end else begin
              next_ss.serial_data_stack[0] = sd.mosi[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      //Combines ack and nack in one state, controlled by 2nd and 3rd entries on serial data stack
      //2nd: The type of ack to send: 0 Ack, 1 Nack
      //3rd (Not sure): state of serial data to set to when process is done
      S_SEND_ACK: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
            next_ss.serial_clk = 1;
            next_ss.serial_data_stack[0] = ss.serial_data_stack[1];
          end
          1: begin
            //Clock stretching
            if (scl) begin
              next_ss.last_ack = 0;
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_clk = 0;
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.process_counter = 0;
            next_ss.state_stack[0] = ss.state_stack[1];
            next_ss.serial_data_stack[0] = 0;
          end
        endcase
      end
      S_STOP: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
            next_ss.serial_clk = 1;
          end
          1: begin
            //Clock stretching
            if (scl) begin
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.serial_data_stack[0] = 1;
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.process_counter = 0;
            next_ss.state_stack[0] = S_IDLE;
          end
        endcase
    	
      end
    endcase
  end 
  // else begin
  //   next_ss.divider_counter = ss.divider_counter + 1;
  // end
end 

always_ff @(posedge clk, negedge reset_n) begin
  if (!reset_n) begin
    ss <= '{
      state_stack: {S_IDLE,S_IDLE,S_IDLE},
      serial_clk: 0,
      serial_data_stack: {0,0,0},
      last_ack: 0,
      process_counter: 0,
      bit_cnt: 0,
      divider_counter: 0,
      busy: 0
    };
  end else begin
    case(ss.state_stack[0]) inside
      S_IDLE, S_CHECK_ACK, S_READ_REG_DATA: begin
        output_data_en <= 0;
      end 
      default: begin
        output_data_en <= 1;
      end
    endcase

    if (ss.state_stack[0] != S_IDLE && ss.process_counter != 1 && ss.process_counter != 2) begin
      output_clk_en <= 1;
    end else begin
      output_clk_en <= 0;
    end

    ss <= next_ss;
    if (ss.divider_counter == divider) begin
      ss.divider_counter <= 0;
    end else begin
      ss.divider_counter <= ss.divider_counter + 1;
    end
  end
end

endmodule
