// %include ips/c

`timescale 1ns/1ps
module main #(
)
(
    input clk,
    input [7:0] JB,
    output reg [3:0] r, g, b,
    inout reg [7:0] JC,
    input [4:0] btn,
    output reg [7:0] led,
    // output [7:4] JC,
    output reg hsync, vsync
);
    wire clk_108, clk_25, clk_100;
    reg start_cam, capture = 1;

    logic [31:0] clk_cnt;

    
    wire div_clk = clk_cnt[$clog2(1_000_000)];

    logic [4:0] buttons;
    genvar i;
    generate
        for(i = 0; i < 5; i++) begin
            debouncer d0 (div_clk, btn[i], buttons[i]);
        end
    endgenerate

    always @(posedge clk) begin
        clk_cnt <= clk_cnt + 1;
    end

    always @(posedge div_clk) begin
        if(buttons[0]) begin
            capture <= ~capture;
        end
    end

    wire bufclk;

    BUFG clkf_buf
        (.O (clk_100),
        .I (clk));

    clk_mcmm cm(.clk_in1(clk_100), .clk_108(clk_108), .clk_25(clk_25), .reset(1'b0), .locked(1'b0));

    localparam D_OFF_X = 700;
    localparam D_OFF_Y = 20;
    localparam C_W = 8;
    localparam C_H = 8;
    localparam STR_LEN = 5;
    localparam SCALE = 4;

    logic [$clog2(SCALE) - 1:0] scale_cntr_x = 0, scale_cntr_y = 0;
    logic [$clog2(128)- 1:0] character_addr;
    wire [C_W*C_H - 1:0] char_buf;
    logic [$clog2(STR_LEN * C_W): 0] x_cntr;
    logic [$clog2(C_H): 0] y_cntr;
    rom #(.WIDTH(C_W*C_H), .DEPTH(128), .binaryFile("ascii.rom")) ascii (.addr(character_addr), .data(char_buf));

    logic [7:0] display_chars [STR_LEN - 1:0];

    logic clka /* synthesis syn_isclock = 1 */;
    logic ena = 1;
    logic [0:0]wea = 0;
    logic [16:0]addra = 0;
    logic [11:0]dina = 0;

    logic clkb /* synthesis syn_isclock = 1 */;
    logic enb;
    logic [16:0]addrb = 0;
    wire [11:0]doutb;

    buffer_mem bm (.clka(clk_25), .ena(ena), .wea(wea), .addra(addra), .dina(dina), .clkb(clk_108), .enb(enb), .addrb(addrb), .doutb(doutb));

    // vga vga_u0 (.pclk(clk_108), .r(r), .g(g), .b(b), .hsync(hsync), .vsync(vsync));
    wire [$clog2(1688):0] x;
    wire [$clog2(1066):0] y;
    wire active;
    vga_ctrl vga_c (.pclk(clk_108), .x(x), .y(y), .hsync(hsync), .vsync(vsync), .active(active));

    assign enb = active;

    assign clkb = clk_108;

    always @(posedge clk_108) begin
        if(active && x <= 640 && y <= 480) begin
            if (x[1:0] == 2'b0) begin
                addrb <= addrb + 1;
            end
            {r,g,b} = doutb;
        end else if (x >= D_OFF_X && x <= (D_OFF_X + STR_LEN * C_W * SCALE)) begin
            if (y >= D_OFF_Y && y <= (D_OFF_Y + C_H * SCALE)) begin
                scale_cntr_x <= scale_cntr_x + 1;
                if(scale_cntr_x == 0) begin
                    x_cntr <= x_cntr + 1;
                    if(x_cntr == STR_LEN * C_W - 1) begin
                        scale_cntr_y <= scale_cntr_y + 1;
                        x_cntr <= 0;
                        if(scale_cntr_y == 0) begin
                            y_cntr <= y_cntr + 1;
                            if(y_cntr == C_H - 1) begin
                                y_cntr <= 0;
                            end
                        end
                    end
                end
                character_addr <= display_chars[x_cntr/C_W][6:0];
                // {r,g,b} <= {12{1'b1}};
                {r,g,b} <= {12{char_buf[(y_cntr * C_W)+ (x_cntr % C_W)]}};
                led <= char_buf[7:0];
                // led[x_cntr % C_W] <= {{char_buf[(y_cntr * C_W )+ (x_cntr % C_W)]}};
            end
        end else begin
            if (y > 480) begin
                addrb <= 0;
            end
            {r,g,b} = 12'b0;
        end
    end

    assign JC[5] = clk_25;
    wire camera_state cam_state;

    wire pclk;
    IBUFG ibuf_inst (
        .I(JC[1]),
        .O(pclk)
    );
    ov7670 cam (.clk(clk_100), .plk(pclk), .D(JB), .vsync(JC[0]), .hsync(JC[2]), .sda(JC[3]), .scl(JC[4]), .xclk(JC[5]), .pwdn(JC[6]), .rst(JC[7]), .start(start_cam), .sys_state(cam_state));


    typedef enum {
        WAIT_FRAME_START,
        ROW_CAPTURE,
        STOP
    } state_t;

    state_t state = WAIT_FRAME_START;
    logic pixel_half = 0;
    logic [1:0] counter = 0;

    //Clock slower than ram
    always @(posedge pclk) begin
        wea <= 0;
        case(state)
            WAIT_FRAME_START: begin
                if(capture) begin
                    state <= (!JC[0]) ? ROW_CAPTURE: WAIT_FRAME_START;
                    addra <= 0;
                end
            end
            ROW_CAPTURE: begin
                state <= (!JC[0]) ? ROW_CAPTURE: WAIT_FRAME_START;
                if(JC[2]) begin
                    pixel_half <= ~pixel_half;
                    if (!pixel_half) begin
                        dina[11:4] <= JB;
                        // dina[11:8] <= JB[7:4];
                        // dina[7:5] <= JB[2:0];
                    end else begin
                        // dina[4] <= JB[7];
                        // dina[3:0] <= JB[4:1];
                        dina[3:0] <= JB[7:4];
                        counter <= counter + 1;
                        wea <= 1;
                        if(counter == 2'b0) begin
                            addra <= addra + 1;
                        end
                    end
                end else begin
                    counter <= 0;
                end
            end
            STOP: begin
                if(btn[0]) begin
                    state <= WAIT_FRAME_START;
                end
            end
        endcase
    end

    initial begin
        counter = 0;
        start_cam = 1;
        display_chars[0] = "h";
        display_chars[1] = "e";
        display_chars[2] = "l";
        display_chars[3] = "l";
        display_chars[4] = "o";
    end
    // assign JC = {1'b0, 1'b0, hsync, vsync};
endmodule
