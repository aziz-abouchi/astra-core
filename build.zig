
const std = @import("std");

pub fn build(b: *std.Build) void {
    // Options standard (compat 0.15.x)
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const enable_eqsat = b.option(bool, "eqsat", "Activer le pass EQSAT") orelse false;

    // ── Binaire principal "astra"
    var root_mod = b.createModule(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
    });
    // Configure le module (et PAS le Step.Compile)
    root_mod.resolved_target = target;
    root_mod.optimize = optimize;

    const exe = b.addExecutable(.{
        .name = "astra",
        .root_module = root_mod,
    });

    if (enable_eqsat) {
        exe.root_module.addCMacro("ASTRA_EQSAT", "1");
    }

    b.installArtifact(exe);

    // ── Exemple "extraction_example"
    var example_mod = b.createModule(.{
        .root_source_file = .{ .cwd_relative = "src/eqsat/examples/extraction_example.zig" },
    });
    example_mod.resolved_target = target;
    example_mod.optimize = optimize;

    const example = b.addExecutable(.{
        .name = "extraction_example",
        .root_module = example_mod,
    });

    b.installArtifact(example);
}

