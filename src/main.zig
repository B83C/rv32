const SYSCON_REG_ADDR: usize = 0x11100000;
const UART_BUF_REG_ADDR: usize = 0x10000000;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);
const std = @import("std");

comptime {
    asm (
        \\.global _start
        \\
    );
}

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("la sp, _sstack");

    for ("Hello oeustnhaoeuworld!\n") |b| {
        uart.* = b;
    }
    // tt();
    uart.* = asm volatile (
        \\ call %[func]
        : [ret] "={a0}" (-> u32),
        : [func] "i" (&tt),
        : "ra"
    );
    // @call(std.builtin.CallModifier.auto, tt, .{});
    syscon.* = 0x5555;
    while (true) {}
}

fn tt() u32 {
    var te: u32 = 0;
    const t: u32 = 8;
    te += 0x239487;
    if (-63 < 63) {
        te += 2;
    }
    asm volatile ("" ::: "memory");
    te ^= 0x1010;
    uart.* = 0x324;
    asm volatile ("" ::: "memory");
    te >>= 3;
    te *= 0x87;
    te *= t;
    asm volatile ("" ::: "memory");
    uart.* = te;
    return te;
    // asm volatile ("nop");
}
