// runtime/repl.zig
const std = @import("std");
const VM = @import("vm.zig").VM;
const bytecode = @import("bytecode.zig");
const ast = @import("ast.zig");

pub fn run() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var vm = VM.init();

    while (true) {
        try stdout.print("Heaven REPL> ", .{});
        try stdout.flush();

        var line_buf: [256]u8 = undefined;
        var reader = std.fs.File.stdin().reader(&line_buf);
        const input = try reader.interface.takeDelimiterExclusive('\n');

        // Parser minimal: convert "dot" to dot instruction
        var exprs: [1]ast.Expr = .{ ast.Expr.Dot{} };
        const code = try bytecode.compile(exprs);
        try vm.execute(code);
    }
}
