const std = @import("std");
const Target = @import("std").Target;
const Feature = @import("std").Target.Cpu.Feature;

const COE_HEADER = "memory_initialization_radix=16;\nmemory_initialization_vector=\n";

pub fn build(b: *std.Build) anyerror!void {
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

    const optimise = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });

    const exe = b.addExecutable(.{
        .name = "rv32_fpga",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        // .optimize = .Debug,
        .optimize = optimise,
    });
    exe.setLinkerScriptPath(b.path("src/linker.ld"));

    const bin = exe.addObjCopy(.{ .format = .bin });

    const generate_bin = b.addInstallBinFile(bin.getOutput(), "rv32_fpga.bin");

    // const generate_coe = b.addInstallBinFile(b.path("rv32_fpga.coe"), "rv32_fpga.coe");

    // const coe_step = b.step("coe", "Generate coe file");
    // ._ = try writeCoe(bin.getOutput().src_path.sub_path, ("rv32_fpga.ceo"));

    // std.debug.print("{b}", .{bin.getOutput()});
    b.getInstallStep().dependOn(&generate_bin.step);
    // coe_step.dependOn(&generate_bin.step);

    const emulate_step = b.step("emu", "Emulate in QEMU");
    const qemu = b.addSystemCommand(&.{"qemu-system-riscv32"});
    qemu.addArgs(&.{ "-M", "virt", "-nographic", "-bios" });
    qemu.addFileArg(generate_bin.source);
    emulate_step.dependOn(&qemu.step);
}

fn writeCoe(bin_path: []const u8, coe_path: []const u8) anyerror!void {
    const allocator = std.heap.page_allocator;
    std.debug.print("Reading from {s}\n", .{bin_path});
    const fs = std.fs;

    const input_file = try fs.cwd().openFile(bin_path, .{ .mode = .read_only });
    defer input_file.close();

    const output_file = try fs.cwd().createFile(coe_path, .{ .mode = 0, .truncate = true });
    defer output_file.close();

    // Write COE header
    try output_file.writeAll("memory_initialization_radix=16;\nmemory_initialization_vector=\n");

    // Read binary data and write as hex
    var reader = input_file.reader();
    // var buffer: [16]u8 = undefined;
    // var first = true;
    const buffer: []u8 = try reader.readAllAlloc(allocator, 128000);
    defer allocator.free(buffer);

    for (buffer) |byte| {
        try std.fmt.format(output_file.writer(), "{x}", .{byte});
    }

    // End COE file
    try output_file.writeAll(";\n");
}
