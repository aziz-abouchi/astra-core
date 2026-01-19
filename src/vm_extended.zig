
const std = @import("std");

pub fn evalFactorialAST(n: usize) usize {
    var acc: usize = 1;
    var i: usize = n;
    while (i > 0) : (i -= 1) {
        acc *= i;
    }
    return acc;
}

pub fn enforceQTTDoubleUse() bool {
    var used: bool = false;
    if (used) return false;
    used = true;
    // simulate second use
    if (used) return false;
    return true;
}

pub fn main() !void {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch unreachable;
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len > 1) {
        const n = std.fmt.parseInt(usize, args[1], 10) catch 5;
        const res = evalFactorialAST(n);
        std.debug.print("AST executed factorial_tail({}) = {}\n", .{ n, res });
    } else {
        std.debug.print("Usage: run <n>\n", .{});
    }
}
