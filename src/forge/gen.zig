const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn emitZig(egraph: *EGraph, id: EGraph.EClassId, writer: anytype) !void {
    const node = egraph.nodes[id];
    switch (node) {
        .Atomic => |h| {
            // Pour le test, on affiche juste "var_[hash]"
            try writer.print("v_{x:0>4}", .{h[0..2]}); 
        },
        .Operation => |op| {
            try writer.print("(", .{});
            try emitZig(egraph, op.left, writer);
            const symbol = switch (op.op) {
                .Add => " + ",
                .Mul => " * ",
                else => " ? ",
            };
            try writer.print("{s}", .{symbol});
            try emitZig(egraph, op.right, writer);
            try writer.print(")", .{});
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => ".", .Cross => "#",
    };
}
