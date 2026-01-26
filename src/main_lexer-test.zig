const std = @import("std");
const lexer_mod = @import("lexer.zig");

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len != 2) {
        std.debug.print("Usage: astra-core <file>\n", .{});
        return;
    }

    const path = args[1];
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const contents = try file.readToEndAlloc(gpa, 1024 * 1024);
    defer gpa.free(contents);

    var lexer = lexer_mod.Lexer.init(contents);

    while (true) {
        const tok = lexer.next();
        std.debug.print("TAG={s} LEX='{s}'\n", .{ @tagName(tok.tag), tok.lexeme });
        if (tok.tag == .EOF) break;
    }
}

