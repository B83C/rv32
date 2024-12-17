`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 16:46:52
// Design Name: 
// Module Name: cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module Cache (
    input wire clk,
    input wire rst,
    input wire [31:0] cpu_req_addr,
    input wire cpu_req_valid,
    input wire cpu_req_wr,
    input wire [31:0] cpu_wr_data,
    output reg [31:0] cpu_rd_data,
    output reg cpu_req_ready,
    output reg [31:0] mem_req_addr,
    output reg mem_req_valid,
    output reg mem_req_wr,
    output reg [127:0] mem_wr_data,
    input wire [127:0] mem_rd_data,
    input wire mem_req_ready
);

localparam V = 1'b1;  // Valid bit
localparam D = 1'b1;  // Dirty bit

// 2路组相联缓存，每路64行，每行128位
reg [141:0] cache_data [63:0][1:0];  // 2路，每行包含Tag+Valid+Dirty+数据
reg [3:0] state, next_state;

// 提取地址中的Tag、Index、Offset
wire [20:0] tag = cpu_req_addr[31:11];
wire [5:0] index = cpu_req_addr[10:5];
wire [4:0] offset = cpu_req_addr[4:0];

// 命中判断
wire hit_way1 = (cache_data[index][0][140] == V) && (cache_data[index][0][139:119] == tag);
wire hit_way2 = (cache_data[index][1][140] == V) && (cache_data[index][1][139:119] == tag);
wire hit = hit_way1 | hit_way2;

// 选择要替换的缓存路，采用**伪LRU策略**，最近使用的路不被替换
reg lru;  // LRU位，0表示路0最近使用，1表示路1最近使用
wire victim_way = lru;  // 选择替换的路

// FSM状态定义
localparam IDLE = 4'b0001, COMPARE = 4'b0010, WRITE_BACK = 4'b0100, ALLOCATE = 4'b1000;

// FSM状态转换
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        IDLE: 
            next_state = (cpu_req_valid) ? COMPARE : IDLE;
        COMPARE: 
            next_state = (hit) ? IDLE : (cache_data[index][victim_way][139] == D) ? WRITE_BACK : ALLOCATE;
        WRITE_BACK: 
            next_state = (mem_req_ready) ? ALLOCATE : WRITE_BACK;
        ALLOCATE: 
            next_state = (mem_req_ready) ? IDLE : ALLOCATE;
        default: 
            next_state = IDLE;
    endcase
end

// 读数据逻辑，支持从128位缓存行中提取32位数据
always @(*) begin
    if (hit_way1) 
        cpu_rd_data = cache_data[index][0][(offset[4:2] * 32) +: 32];  // 通过offset提取32位数据
    else if (hit_way2) 
        cpu_rd_data = cache_data[index][1][(offset[4:2] * 32) +: 32];
    else 
        cpu_rd_data = 32'd0;
end

// 处理写操作
always @(posedge clk) begin
    if (cpu_req_wr && hit) begin
        if (hit_way1) 
            cache_data[index][0][(offset[4:2] * 32) +: 32] <= cpu_wr_data;
        else if (hit_way2) 
            cache_data[index][1][(offset[4:2] * 32) +: 32] <= cpu_wr_data;
        cache_data[index][victim_way][D] <= 1'b1;  // 设置为脏行
    end
end

// 内存写回逻辑
always @(posedge clk) begin
    if (state == WRITE_BACK) begin
        mem_req_addr <= {cache_data[index][victim_way][139:119], index, 5'b0};  // 使用原始Tag+Index
        mem_req_valid <= 1'b1;
        mem_req_wr <= 1'b1;
        mem_wr_data <= cache_data[index][victim_way][127:0];  // 写回整个128位缓存行
    end else begin
        mem_req_valid <= 1'b0;
    end
end

// LRU替换策略
always @(posedge clk) begin
    if (hit) begin
        if (hit_way1) 
            lru <= 1'b1;  // 0路最近使用
        else if (hit_way2) 
            lru <= 1'b0;  // 1路最近使用
    end
end

// 内存读取逻辑
always @(posedge clk) begin
    if (state == ALLOCATE && mem_req_ready) begin
        cache_data[index][victim_way][127:0] <= mem_rd_data;  // 加载128位数据
        cache_data[index][victim_way][139:119] <= tag;  // 存储Tag
        cache_data[index][victim_way][140] <= V;  // 设置有效位
        cache_data[index][victim_way][D] <= 1'b0;  // 新加载的数据是干净的
    end
end

endmodule
