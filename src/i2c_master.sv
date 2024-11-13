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
  IDLE,
  START,
  WRITE_ADDR,
  CHECK_ACK,
  WRITE_REGISTER_ADDR,
  WRITE_REG_DATA,
  READ_REG_DATA,
  RESTART,
  SEND_ACK,
  STOP
} state_type;

typedef struct {
  reg [ADDRESS_WIDTH:0] device_addr;
  reg [REGISTER_ADDR_WIDTH-1:0] reg_addr;
  reg [DATA_WIDTH-1:0] mosi;
  reg [DATA_WIDTH-1:0] miso;
  reg rw;
} saved_data;

typedef struct {
  state_type state [2:0];
  reg scl;
  reg sda [2:0];
  reg last_ack;

  reg [1:0] process_counter;
  reg [4:0] bit_cnt;

  reg [15:0] divider_counter;

  reg busy;
} system_state;

saved_data sd;
system_state ss;
system_state next_ss;

reg sda_en;
reg scl_en;
assign sda = sda_en? ss.sda[0]: 1'bz;
assign scl = scl_en? ss.scl: 1'bz;
assign busy = ss.busy;
assign miso = sd.miso;

always_comb begin
  next_ss = ss;
  if (ss.divider_counter == divider) begin
    next_ss.divider_counter = 0;
    case (ss.state[0]) 
      IDLE: begin
        if(en) begin
          sd.mosi = mosi;
          sd.device_addr = {device_addr, 1'b0};
          sd.reg_addr = register_addr;
          sd.rw = rw;
          next_ss.busy = 1;
          next_ss.state[0] = START;
          next_ss.state[1] = WRITE_ADDR;
          next_ss.state[2] = WRITE_REGISTER_ADDR;
          next_ss.sda[0] = 1;
          next_ss.sda[2] = sd.reg_addr[REGISTER_ADDR_WIDTH - 1];
          next_ss.bit_cnt = 8;
        end
      end
      START: begin
        case (ss.process_counter) 
          0: begin
            next_ss.scl = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            next_ss.sda[0] = 0;
            next_ss.process_counter = 2;
          end
          2: begin
              next_ss.process_counter = 3;
          end
          3: begin
            next_ss.scl = 0;
            next_ss.process_counter = 0;
            next_ss.state[0] = ss.state[1];
            next_ss.sda[0] = sd.device_addr[ADDRESS_WIDTH];
            //Write device address with w bit set on start
            next_ss.state[1] = ss.state[2];
            next_ss.sda[1] = ss.sda[2];
          end
        endcase
        // next_ss.scl = ~ss.process_counter[1];
        // next_ss.process_counter = ss.process_counter + {1'b0, (ss.process_counter == 1) & scl}; //Allow for clock stretching
        // next_ss.sda[0] = 
      end
      WRITE_ADDR: begin
        case (ss.process_counter)
          0: begin
            next_ss.scl = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if (scl) begin //Clock stretching
              next_ss.last_ack = 0;
            	next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.scl = 0;
            next_ss.bit_cnt = ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if(ss.bit_cnt == 0) begin
              next_ss.state[0] = CHECK_ACK;
              // next_ss.sda[0] = 0; //rw bit! W is active low, not sure about that ...
              //Hack!
              if (ss.state[1] == READ_REG_DATA) begin
                next_ss.bit_cnt = DATA_WIDTH;
              end else begin
                next_ss.bit_cnt = REGISTER_ADDR_WIDTH;
              end
            end
            else begin
              next_ss.sda[0] = sd.device_addr[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      CHECK_ACK: begin
        case (ss.process_counter) 
          0: begin
            next_ss.scl = 1;
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
            next_ss.scl = 0;
            if (sda == 0) begin
              next_ss.last_ack = 1;
            end          
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.last_ack)  begin
              next_ss.state[0] = ss.state[1];
              next_ss.sda[0] = ss.sda[1];
              next_ss.last_ack = 0;
            end else begin
              next_ss.state[0] = STOP;
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      WRITE_REGISTER_ADDR: begin
        case (ss.process_counter) 
          0: begin
            next_ss.scl = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if (scl) begin //Check for clock stretching
            	next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.scl = 0;
            next_ss.bit_cnt = next_ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.state[0] = CHECK_ACK;
              if (ss.bit_cnt[3]) begin //16 bit case
                next_ss.state[1] = WRITE_REGISTER_ADDR;
                next_ss.sda[1] = sd.reg_addr[ss.bit_cnt - 1];
              end else begin
                if (sd.rw) begin
                  next_ss.state[1] = RESTART; //Reading requires restarting the process
                  next_ss.sda[1] = 1;
                end else begin
                  next_ss.state[1] = WRITE_REG_DATA;
                  next_ss.sda[1] = sd.mosi[DATA_WIDTH - 1];
                end
              end
            end else begin
              next_ss.sda[0] = sd.reg_addr[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      //*REQUIREMENT* Assuming that before entering restart that serial data has been set to high 
      RESTART: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
          end
          1: begin
            next_ss.scl = 1;
            next_ss.process_counter = 3;
          end
          2: begin
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.state[0] = START;
            next_ss.state[1] = WRITE_ADDR;
            next_ss.state[2] = READ_REG_DATA;
            next_ss.sda[2] = 0;
            sd.device_addr[0] = 1;
            // next_ss.sda[1] = 1; //TODO
            next_ss.process_counter = 0;
          end
        endcase
      end
      READ_REG_DATA: begin
        case(ss.process_counter)
          0: begin
            next_ss.process_counter = 1;
            next_ss.scl = 1;
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
            next_ss.scl = 0; 
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.sda[0] = 0;
                next_ss.state[0] = SEND_ACK;
              if (ss.bit_cnt[3]) begin
                next_ss.sda[1] = 0; //Ack
                // next_ss.sda[2] = 0; //Ack follow previous data state
                next_ss.state[1] = READ_REG_DATA;
              end else begin
                next_ss.sda[1] = 1; //Nack
                // next_ss.sda[2] = 0; //Nack idk why 
                next_ss.state[1] = STOP;
              end
            end else begin
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      WRITE_REG_DATA: begin
        case(ss.process_counter)
          0: begin
            next_ss.scl = 1;
            next_ss.process_counter = 1;
          end
          1: begin
            if(scl) begin
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.scl = 0;
            next_ss.bit_cnt = ss.bit_cnt - 1;
            next_ss.process_counter = 3;
          end
          3: begin
            if (ss.bit_cnt[2:0] == 3'd0) begin
              next_ss.state[0] = CHECK_ACK;
              if (ss.bit_cnt[3]) begin //16 bit case
                next_ss.state[1] = WRITE_REG_DATA;
                next_ss.sda[1] = sd.mosi[ss.bit_cnt - 1];
              end else begin
                next_ss.state[1] = STOP;
              end
            end else begin
              next_ss.sda[0] = sd.mosi[ss.bit_cnt - 1];
            end
            next_ss.process_counter = 0;
          end
        endcase
      end
      //Combines ack and nack in one state, controlled by 2nd and 3rd entries on serial data stack
      //2nd: The type of ack to send: 0 Ack, 1 Nack
      //3rd (Not sure): state of serial data to set to when process is done
      SEND_ACK: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
            next_ss.scl = 1;
            next_ss.sda[0] = ss.sda[1];
          end
          1: begin
            //Clock stretching
            if (scl) begin
              next_ss.last_ack = 0;
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.scl = 0;
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.process_counter = 0;
            next_ss.state[0] = ss.state[1];
            next_ss.sda[0] = 0;
          end
        endcase
      end
      STOP: begin
        case(ss.process_counter) 
          0: begin
            next_ss.process_counter = 1;
            next_ss.scl = 1;
          end
          1: begin
            //Clock stretching
            if (scl) begin
              next_ss.process_counter = 2;
            end
          end
          2: begin
            next_ss.sda[0] = 1;
            next_ss.process_counter = 3;
          end
          3: begin
            next_ss.process_counter = 0;
            next_ss.state[0] = IDLE;
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
      state: {IDLE,IDLE,IDLE},
      scl: 0,
      sda: {0,0,0},
      last_ack: 0,
      process_counter: 0,
      bit_cnt: 0,
      divider_counter: 0,
      busy: 0
    };
  end else begin
    case(ss.state[0]) inside
      IDLE, CHECK_ACK, READ_REG_DATA: begin
        sda_en <= 0;
      end 
      default: begin
        sda_en <= 1;
      end
    endcase

    if (ss.state[0] != IDLE && ss.process_counter != 1 && ss.process_counter != 2) begin
      scl_en <= 1;
    end else begin
      scl_en <= 0;
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
