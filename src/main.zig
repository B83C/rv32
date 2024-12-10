const SYSCON_REG_ADDR: usize = 0x11100000;
const UART_BUF_REG_ADDR: usize = 0x10000000;

const syscon: *volatile u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("la sp, _sstack");

    for ("Hello world!\n") |b| {
        uart.* = b;
    }
    syscon.* = 0x5555;
    while (true) {}
}
