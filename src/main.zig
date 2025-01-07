const D_OFF_X = 700;
const D_OFF_Y = 20;
const C_W = 8;
const C_H = 8;
const SCALE_X = 2;
const SCALE_Y = 2;

const HCC = 1280 / (C_W * SCALE_X);
const VCC = 1024 / (C_H * SCALE_Y);
const x_bound = HCC * C_W * SCALE_X;
const y_bound = VCC * C_H * SCALE_Y;

const SYSCON_REG_ADDR: usize = (128 + 78) * 1024;
const UART_BUF_REG_ADDR: usize = SYSCON_REG_ADDR + 4;

const IO_REGISTER_READ: usize = (128) * 1024;
const IO_REGISTER_WRITE: usize = (128 + 64) * 1024;
const VGA_BUFFER: usize = (256) * 1024;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);

const io_reg_write: *volatile io_w = @ptrFromInt(IO_REGISTER_WRITE);
const io_reg_read: *volatile io_r = @ptrFromInt(IO_REGISTER_READ);
const vga: *volatile vga_t = @ptrFromInt(VGA_BUFFER);

const std = @import("std");

const vga_t = [64][128]u8;

const io_r = packed struct {
    vga_active: u8,
    gpio: gpio_state,
    uart: uart_r_state,
};

const io_w = struct {
    uart: uart_w_state,
    gpio_mode: gpio_state,
    gpio: gpio_state,
    sseg: [4]u8,
};

const gpio_state = packed struct {
    JC: u8,
    JB: u8,
    leds: u16,
};

const uart_r_state = packed struct {
    rx: u8,
    state: u8,
    padding: u16,
};

const uart_w_state = packed struct {
    tx: u8,
    ctrl: u8,
    padding: u16,
};

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("la sp, _sstack");
    asm volatile ("la s0, _sstack");

    asm volatile (
        \\ call %[func]
        :
        : [func] "i" (&main),
        : "ra"
    );
    // @call(std.builtin.CallModifier.auto, tt, .{});
    // syscon.* = 0x5555;
    while (true) {}
}

export fn delay(max: u32) void {
    var cnt: u32 = 0;
    while (cnt < max) cnt += 1;
}

inline fn uart_send(chr: u8) void {
    while ((io_reg_read.uart.state & 0b100) == 0) {}
    io_reg_write.uart.tx = chr;
    io_reg_write.uart.ctrl = 0b100;
    delay(1000);
    io_reg_write.uart.ctrl = 0;
}

fn main() noreturn {
    var led: u16 = 0x3;
    io_reg_write.gpio_mode.leds = 0xFF; //output
    for ("hello world\n!", 0..) |b, i| {
        vga[0][i] = b;
    }
    // std.mem.copyForwards(u8,, "hello");
    while (true) {
        const xmin: i32 = -8601;
        const xmax: i32 = 2867;
        const ymin: i32 = -4915;
        const ymax: i32 = 4915;

        const maxiter: usize = 32;

        const dx: i32 = @divTrunc((xmax - xmin), 79);
        const dy: i32 = @divTrunc((ymax - ymin), 24);

        var cy = ymin;

        var xc: usize = 0;
        var yc: usize = 0;

        syscon.* = @as(u32, @intCast(dx));
        syscon.* = @as(u32, @intCast(dy));
        while (cy <= ymax) {
            var cx = xmin;
            while (cx <= xmax) {
                var x: i32 = 0;
                var y: i32 = 0;
                var x2: i32 = 0;
                var y2: i32 = 0;
                var iter: usize = 0;
                while (iter < maxiter) : (iter += 1) {
                    if (x2 + y2 > 16384) break;
                    y = ((x * y) >> 11) + cy;
                    x = x2 - y2 + cx;
                    x2 = (x * x) >> 12;
                    y2 = (y * y) >> 12;
                    syscon.* = @as(u32, @intCast(x));
                    syscon.* = @as(u32, @intCast(y));
                    syscon.* = @as(u32, @intCast(x2));
                    syscon.* = @as(u32, @intCast(y2));
                }
                xc += 1;
                vga[@as(usize, @intCast(yc))][@as(usize, @intCast(xc))] = ' ' + @as(u8, @intCast(iter));
                // uart_send(' ' + @as(u8, @intCast(iter)));
                cx += dx;
            }
            xc = 0;
            yc += 1;
            // uart_send('\r');
            // uart_send('\n');
            cy += dy;
        }
        // while ((io_reg_read.uart.state & 0b10) == 0) {}
        // for ("Hello world\r\n") |b| {
        //     io_reg_write.uart.ctrl = 0b100;
        //     delay(100000);
        //     io_reg_write.uart.ctrl = ~@as(u8, 0b100);
        // }
        io_reg_write.gpio.leds = led;
        led = std.math.rotl(u16, led, 1);
        delay(1000000);
        // while ((io_reg_read.uart.state & 0b100) > 0) {
        //     // io_reg_write.uart.ctrl = 0;
        //     // delay();
        //     // io_reg_write.uart.tx = 'C';
        //     // delay();
        //     // io_reg_write.uart.ctrl = 4;
        //     // uart.* = 'A';
        // }
    }
}
