const SYSCON_REG_ADDR: usize = 0x11100000;
const UART_BUF_REG_ADDR: usize = 0x10000000;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);
const std = @import("std");

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("la sp, _sstack");

    for ("Hello oeustnhaoeuworld!\n") |b| {
        uart.* = b;
    }
    asm volatile ("call tt");
    // @call(std.builtin.CallModifier.auto, tt, .{});
    syscon.* = 0x5555;
    while (true) {}
}

export fn tt() void {
    var te: u32 = 0;
    te += 0x239487;
    if (-63 < 63) {
        te += 2;
    }
}
