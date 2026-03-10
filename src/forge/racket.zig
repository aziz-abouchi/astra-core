const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |name| buf.print("{s}", .{std.mem.trim(u8, &name, " ")}),
        .Scalar => |val| buf.print("{d}", .{val.toF64()}),
        .Operation => |op| {
            buf.print("({s} ", .{getSymbol(op.op)});
            emit(eg, op.left, buf);
            buf.print(" ", .{});
            emit(eg, op.right, buf);
            buf.print(")", .{});
        },
        .Vector => |v| buf.print("(vector {d} {d} {d})", .{v.data[0].toF64(), v.data[1].toF64(), v.data[2].toF64()}),
        .Hole => {
            buf.print("???", .{}); // Ou une représentation visuelle d'un trou
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "dot-product", .Cross => "cross-product",
    };
}
