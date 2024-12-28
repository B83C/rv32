const SYSCON_REG_ADDR: usize = (128 + 78) * 1024;
const UART_BUF_REG_ADDR: usize = SYSCON_REG_ADDR + 4;

const IO_REGISTER_READ: usize = (128) * 1024;
const IO_REGISTER_WRITE: usize = (128 + 64) * 1024;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);

const io_reg_write: *volatile io_w = @ptrFromInt(IO_REGISTER_WRITE);
const io_reg_read: *volatile io_r = @ptrFromInt(IO_REGISTER_READ);

const io_r = packed struct {
    gpio: gpio_state,
    uart: uart_r_state,
};

const io_w = packed struct {
    uart: uart_w_state,
    gpio: gpio_state,
    sseg: *[4]u8,
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
    syscon.* = 0x5555;
    while (true) {}
}

fn delay() void {
    var cnt: u32 = 0;
    while (cnt < 1) cnt += 1;
}

fn main() noreturn {
    for ("Hello world\n") |b| {
        uart.* = b;
    }
    while (true) {
        while ((io_reg_read.uart.state & 0b100) > 0) {
            io_reg_write.uart.ctrl = 0;
            delay();
            io_reg_write.uart.tx = 'C';
            delay();
            io_reg_write.uart.ctrl = 4;
            uart.* = 'A';
        }
    }
}
