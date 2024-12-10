const std = @import("std");
const Target = @import("std").Target;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *std.Build) void {
    const features = Target.riscv.Feature;
    var disabled_features = Feature.Set.empty;
    var enabled_features = Feature.Set.empty;

    for ([_]Target.riscv.Feature{ features.a, features.c, features.d, features.e, features.f }) |f| {
        disabled_features.addFeature(@intFromEnum(f));
    }

    for ([_]Target.riscv.Feature{features.m}) |f| {
        enabled_features.addFeature(@intFromEnum(f));
    }

    const target = b.resolveTargetQuery(std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .cpu_features_add = enabled_features,
        .cpu_features_sub = disabled_features,
    });

    const exe = b.addExecutable(.{
        .name = "rv32_fpga",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });
    exe.setLinkerScriptPath(b.path("src/linker.ld"));

    const bin = exe.addObjCopy(.{ .format = .bin });

    const generate_bin = b.addInstallBinFile(exe.getOutput(), "rv32_fpga.bin");
    b.getInstallStep().dependOn(&generate_bin.step);

    const emulate_step = b.step("emu", "Emulate in QEMU");
    const qemu = b.addSystemCommand(&.{"qemu-system-riscv32"});
    qemu.addArgs(&.{ "-M", "virt", "-nographic", "-bios" });
    qemu.addFileArg(copy_bin.source);
    emulate_step.dependOn(&qemu.step);
}
