const std = @import("std");
const Parser = @import("parser.zig").Parser;
const ast = @import("ast.zig");
const typechecker = @import("typechecker.zig");
const types = @import("types.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: astra-core <file>\n", .{});
        return;
    }

    const path = args[1];
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 10_000_000);
    defer allocator.free(content);

    var parser = Parser.init(allocator, content);
    const expr = try parser.parseExpr();

    std.debug.print("=== AST ===\n", .{});
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try expr.dump(stdout, 0);

    var env = typechecker.TypeEnv.init(allocator);
    const ty = try typechecker.infer(&env, allocator, expr);
    _ = ty;

    std.debug.print("Type inference OK (placeholder types).\n", .{});
}

