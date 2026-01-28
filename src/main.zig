const std = @import("std");
const Parser = @import("parser.zig").Parser;
const typechecker = @import("typechecker.zig");
const pretty = @import("pretty.zig");

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len != 2) {
        std.debug.print("Usage: astra-core <file>\n", .{});
        return;
    }

    const contents = try std.fs.cwd().readFileAlloc(gpa, args[1], 1 << 20);
    defer gpa.free(contents);

    var parser = Parser.init(gpa, contents);
    const expr = try parser.parseExpr();

    var env = typechecker.TypeEnv.init(gpa);
    const ty = try typechecker.infer(&env, gpa, expr);

    const scheme = typechecker.generalize(&env, ty, gpa);
    const s = pretty.ppScheme(scheme, gpa);

    std.debug.print("Type: {s}\n", .{s});
}

