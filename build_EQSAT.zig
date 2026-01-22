const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const enable_eqsat = b.option(bool, "eqsat", "Activer le pass EQSAT") orelse false;

    // --- main binary ---
    var root_mod = b.createModule(.{ .root_source_file = .{ .cwd_relative = "src/main.zig" } });
    root_mod.resolved_target = target;
    root_mod.optimize = optimize;

    const exe = b.addExecutable(.{ .name = "astra", .root_module = root_mod });
    if (enable_eqsat) {
        exe.root_module.addCMacro("ASTRA_EQSAT", "1");
    }
    b.installArtifact(exe);

    // --- example binary ---
    var example_mod = b.createModule(.{ .root_source_file = .{ .cwd_relative = "src/eqsat/examples/extraction_example.zig" } });
    example_mod.resolved_target = target;
    example_mod.optimize = optimize;

    const eqsat_pass_mod = b.createModule(.{ .root_source_file = .{ .cwd_relative = "src/eqsat/eqsat_pass.zig" } });
    example_mod.addImport("eqsat_pass", eqsat_pass_mod);

    const example = b.addExecutable(.{ .name = "extraction_example", .root_module = example_mod });
    b.installArtifact(example);
}
