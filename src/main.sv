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

    clk_mcmm cm(.clk(clk_100), .clk_108(clk_108), .clk_25(clk_25), .reset(1'b0), .locked(1'b0));

    localparam D_OFF_X = 700;
    localparam D_OFF_Y = 20;
    localparam C_W = 8;
    localparam C_H = 8;
    localparam SCALE = 4;

    localparam HCC = 1280/(C_W * SCALE);
    localparam VCC = 1080/(C_H * SCALE);

    logic [$clog2(SCALE) - 1:0] scale_cntr_x = 0, scale_cntr_y = 0;

    logic [7 - 1:0] text_buffer [1280/(C_W*SCALE) - 1: 0][1080/(C_H*SCALE) - 1: 0];

    logic [$clog2(C_W) - 1: 0] x_cntr;
    logic [$clog2(C_H) - 1: 0] y_cntr;
    logic [$clog2(HCC) - 1: 0] c_x;
    logic [$clog2(VCC) - 1: 0] c_y;
    logic [$clog2(128)- 1:0] character_addr;
    wire [C_W*C_H - 1: 0] char_buf;
    wire char_pix [C_H - 1 : 0][C_W - 1 : 0];
    assign char_pix = {>>{char_buf}};
    rom #(.WIDTH(C_W*C_H), .DEPTH(128), .binaryFile("ascii.rom"), .RISING_EDGE(0)) ascii (.addr(character_addr), .data(char_buf), .clk(clk_108));


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
    wire [$clog2(1280):0] x;
    wire [$clog2(1024):0] y;
    wire active;
    vga_ctrl vga_c (.pclk(clk_108), .x(x), .y(y), .hsync(hsync), .vsync(vsync), .active(active));

    assign enb = active;
    assign clkb = clk_108;

    always @(posedge clk_108) begin
        // character_addr <= 7'd38;
        if (active) begin
            scale_cntr_x <= scale_cntr_x + 1;
            if(scale_cntr_x == SCALE - 1) begin
                scale_cntr_x <= 0;
                x_cntr <= x_cntr + 1;
                if(x_cntr == C_W - 1) begin
                    x_cntr <= 0;
                    c_x <= c_x + 1;
                    if (c_x == HCC - 1) begin
                        c_x <= 0;
                        scale_cntr_y <= scale_cntr_y + 1;
                        if(scale_cntr_y == SCALE - 1) begin
                            scale_cntr_y <= 0;
                            y_cntr <= y_cntr + 1;
                            if(y_cntr == C_H - 1) begin
                                y_cntr <= 0;
                                c_y <= c_y + 1;
                                if (c_y == HCC - 1) begin
                                    c_y <= 0;
                                    character_addr <= text_buffer[c_x][0];
                                end else begin
                                    character_addr <= text_buffer[c_x][c_y + 1];
                                end
                            end
                        end else begin
                            character_addr <= text_buffer[0][c_y];
                        end
                    end else begin
                        character_addr <= text_buffer[c_x + 1][c_y];
                    end
                end 
            end
            {r,g,b} <= {12{char_pix[y_cntr][x_cntr]}};
            // {r,g,b} <= {12{char_buf[(y_cntr * C_W) + (x_cntr % C_W)]}};
        end else begin
        	
        end
        if(active && x < 640 && y < 480) begin
            if (x[1:0] == 2'b11) begin
                addrb <= addrb + 1;
            end
            {r,g,b} = doutb;
        end else if (x >= D_OFF_X && x < (D_OFF_X + STR_LEN * C_W * SCALE)) begin
            if (y >= D_OFF_Y && y < (D_OFF_Y + C_H * SCALE)) begin
                {r,g,b} <= {12{char_buf[(y_cntr * C_W) + (x_cntr % C_W)]}};
            end
        end else begin
            if (y >= 480) begin
                addrb <= 0;
            end
            scale_cntr_x <= 0;
            scale_cntr_x <= 0;
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
                    pixel_half <= 0;
                end
            end
            ROW_CAPTURE: begin
                state <= (!JC[0]) ? ROW_CAPTURE: WAIT_FRAME_START;
                if(JC[2]) begin
                    pixel_half <= ~pixel_half;
                    if (!pixel_half) begin
                        dina[11:4] <= JB;
                        counter <= counter + 1;
                        if(counter == 2'b11) begin
                            addra <= addra + 1;
                        end
                    end else begin
                        dina[3:0] <= JB[7:4];
                        wea <= 1;
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
        text_buffer[20][1] = "h";
        text_buffer[20][2] = "e";
        text_buffer[20][3] = "l";
        text_buffer[20][4] = "l";
        text_buffer[20][5] = "o";
        // display_chars[0] = "h";
        // display_chars[1] = "e";
        // display_chars[2] = "l";
        // display_chars[3] = "l";
        // display_chars[4] = "o";
    end
    // assign JC = {1'b0, 1'b0, hsync, vsync};
endmodule
