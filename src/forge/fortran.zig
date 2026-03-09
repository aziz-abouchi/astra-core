const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("program main\n", .{});
    buf.print("  print *, ", .{});
    emit(eg, id, buf); // Appel de la logique d'expression
    buf.print("\nend program main\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |name| buf.print("{s}", .{std.mem.trim(u8, &name, " ")}),
        .Constant => |val| buf.print("{d}_8", .{val}), // Précision double en Fortran
        .Operation => |op| {
            switch (op.op) {
                .Dot => {
                    buf.print("dot_product(", .{});
                    emit(eg, op.left, buf);
                    buf.print(", ", .{});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
                .Cross => {
                    // Pour que ça compile, il faudrait définir cette fonction !
                    buf.print("astra_cross_product(", .{});
                    emit(eg, op.left, buf);
                    buf.print(", ", .{});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
                else => {
                    buf.print("(", .{});
                    emit(eg, op.left, buf);
                    buf.print(" {s} ", .{getSymbol(op.op)});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
            }
        },
        .Vector => |v| {
            buf.print("[", .{});
            for (v.data, 0..) |val, i| buf.print("{d}_8{s}", .{ val, if (i < v.data.len - 1) ", " else "" });
            buf.print("]", .{});
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "dot", .Cross => "cross",
    };
}
