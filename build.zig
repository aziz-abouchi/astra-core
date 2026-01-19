const std = @import("std");

fn mkExe(b: *std.Build, name: []const u8, path: []const u8, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    const root_mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{ .name = name, .root_module = root_mod });
    const ts_path = "vendor/tree-sitter-astra/src/parser.c";
    if (std.fs.cwd().access(ts_path, .{})) |_| {
        exe.addCSourceFile(.{ .file = b.path(ts_path), .flags = &.{} });
    } else |_| {}
    b.installArtifact(exe);
    return exe;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    _ = mkExe(b, "astra-xtranspile", "src/tools/transpile/astra-xtranspile.zig", target, optimize);
    _ = mkExe(b, "astra-golden",     "src/tools/golden/golden-runner.zig",     target, optimize);
    _ = mkExe(b, "astra-repl",       "src/tools/repl/astra-repl.zig",          target, optimize);
    _ = mkExe(b, "astra-compile",    "src/tools/compiler/astra-compile.zig",   target, optimize);
    _ = mkExe(b, "astra-prof",       "src/tools/profiler/astra-prof.zig",      target, optimize);
    _ = mkExe(b, "astra-analyze",    "src/tools/analyzer/astra-analyze.zig",   target, optimize);
    _ = mkExe(b, "astra-dbg",        "src/tools/debugger/astra-dbg.zig",       target, optimize);
    _ = mkExe(b, "ir-interpreter",   "src/tools/interpreter/ir-interpreter.zig", target, optimize);
}
