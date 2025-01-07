`timescale 1ns / 1ps
`include "defs.svh"

module cache #(
    WAYS = 2,
    WIDTH_BITS = 64,
    BYTES = 128 * 1024,
    localparam WIDTH_BYTES = WIDTH_BITS/8,
    localparam DEPTH = BYTES/WIDTH_BYTES,
    localparam ADDR_BITS = $clog2(DEPTH)
)
(
    input wire clk,
    input wire rst,
    input wire [16:0] cpu_req_addr,
    input wire cpu_req_valid,
    input wire cpu_req_wr,
    input wire [31:0] cpu_wr_data,
    output reg [31:0] cpu_rd_data,
    output reg cpu_req_ready,
    output reg [16:0] mem_req_addr,
    output reg mem_req_valid,
    output reg mem_req_wr,
    output reg [127:0] mem_wr_data,
    input wire [127:0] mem_rd_data,
    input wire mem_req_ready
);

  typedef struct packed {
    logic [3:0][31:0] data;  //Packed
    logic [7:0] tag;
    logic valid;
    logic dirty;
  } cache_entry_t;

  typedef enum {
    IDLE,
    COMPARE,
    WRITE_BACK,
    ALLOCATE
  } state_t;

  // 2路组相联缓存，每路64行，每行128位
  // 128 + 6(Tag) + 2
  // reg [136 - 1:0] cache_data [63:0][1:0];  // 2路，每行包含Tag+Valid+Dirty+数据
  (* ram_style = "distributed" *) cache_entry_t cache_data[15:0][WAYS - 1:0];  // 2路，每行包含Tag+Valid+Dirty+数据
  state_t state, next_state;

  // 提取地址中的Tag、Index、Offset
  // 128KB RAM, 17 bits of address
  wire [7:0] tag = cpu_req_addr[16:9];
  wire [3:0] index = cpu_req_addr[8:5];
  wire [4:0] offset = cpu_req_addr[4:0];

  // 命中判断
  wire hit_way1 = (cache_data[index][0].valid) && (cache_data[index][0].tag == tag);
  wire hit_way2 = (cache_data[index][1].valid) && (cache_data[index][1].tag == tag);
  wire hit = hit_way1 | hit_way2;

  // 选择要替换的缓存路，采用**伪LRU策略**，最近使用的路不被替换
  reg lru;  // LRU位，0表示路0最近使用，1表示路1最近使用
  wire victim_way = lru;  // 选择替换的路


  // FSM状态转换
  always @(posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
  end

  always_comb begin
    case (state)
      // IDLE: next_state = (cpu_req_valid)? COMPARE: IDLE;
      IDLE: next_state = (cpu_req_valid)? (!hit)? (cache_data[index][victim_way].dirty)? WRITE_BACK: ALLOCATE: IDLE: IDLE;
      // COMPARE:
      //   next_state = (hit) ? IDLE : (cache_data[index][victim_way].dirty == 1) ? WRITE_BACK : ALLOCATE;
      WRITE_BACK: next_state = (mem_req_ready) ? ALLOCATE : WRITE_BACK;
      ALLOCATE: next_state = (mem_req_ready) ? IDLE : ALLOCATE;
      default: next_state = IDLE;
    endcase
  end

  // 读数据逻辑，支持从128位缓存行中提取32位数据
  always @(*) begin
    if (hit_way1)
      cpu_rd_data = cache_data[index][0].data[offset[4:2]];  // 通过offset提取32位数据
    else if (hit_way2) cpu_rd_data = cache_data[index][1].data[offset[4:2]];
    else cpu_rd_data = 32'd0;
  end

  // 处理写操作
  always @(posedge clk) begin
    if (cpu_req_wr && hit) begin
      if (hit_way1) cache_data[index][0].data[offset[4:2]] <= cpu_wr_data;
      else if (hit_way2) cache_data[index][1].data[offset[4:2]] <= cpu_wr_data;
      cache_data[index][victim_way].dirty <= 1;  // 设置为脏行
    end else if (state == ALLOCATE && mem_req_ready) begin
      cache_data[index][victim_way] <= '{
        mem_rd_data,
        tag,
        1,
        0
      };
    end
  end

  // 内存写回逻辑
  always @(posedge clk) begin
    if (state == WRITE_BACK) begin
      mem_req_addr <= {cache_data[index][victim_way].tag, index, 5'b0};  // 使用原始Tag+Index
      mem_req_valid <= 1'b1;
      mem_req_wr <= 1'b1;
      mem_wr_data <= cache_data[index][victim_way].data;  // 写回整个128位缓存行
    end else begin
      mem_req_valid <= 1'b0;
    end
  end

  // LRU替换策略
  always @(posedge clk) begin
    if (hit) begin
      if (hit_way1) lru <= 1'b1;  // 0路最近使用
      else if (hit_way2) lru <= 1'b0;  // 1路最近使用
    end
  end


endmodule
