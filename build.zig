const std = @import("std");
// const CrossTarget = @import("std").zig.CrossTarget;
const Target = @import("std").Target;
const Feature = @import("std").Target.Cpu.Feature;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
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

    // b.installArtifact(exe);

    const bin = b.addObjCopy(exe.getEmittedBin(), .{
        .format = .bin,
    });
    bin.step.dependOn(&exe.step);

    const copy_bin = b.addInstallBinFile(bin.getOutput(), "rv32_fpga.bin");
    b.default_step.dependOn(&copy_bin.step);
}
