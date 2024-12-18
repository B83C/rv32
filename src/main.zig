const SYSCON_REG_ADDR: usize = (128 + 78) * 1024;
const UART_BUF_REG_ADDR: usize = SYSCON_REG_ADDR + 4;

const IO_REGISTER_READ: usize = (128) * 1024;
const IO_REGISTER_WRITE: usize = (128 + 64) * 1024;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);

const io_reg_write: *volatile u32 = @ptrFromInt(IO_REGISTER_READ);
const io_reg_read: *volatile u32 = @ptrFromInt(IO_REGISTER_WRITE);
const io_reg_read_1: *volatile uart_state = @ptrFromInt(IO_REGISTER_WRITE + 4);
const std = @import("std");

const uart_state = packed struct {
    rx: u8,
    state: u8,
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

fn main() noreturn {
    for ("Hello world!\n") |b| {
        uart.* = b;
    }
    while ((io_reg_read_1.state >> 3) & 0b1 > 0) {
        uart.* = 'A';
    }
    while (true) {}
}
