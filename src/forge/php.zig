const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |name| buf.print("${s}", .{std.mem.trim(u8, &name, " ")}),
        .Constant => |val| buf.print("{d}", .{val}),
        .Operation => |op| {
            if (op.op == .Dot) {
                buf.print("Vector::dot(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{getSymbol(op.op)});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Vector => |v| buf.print("new Vector3({d}, {d}, {d})", .{v.x, v.y, v.z}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "dot", .Cross => "cross",
    };
}
