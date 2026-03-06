const std = @import("std");
const EGraph = @import("../saturation/egraph.zig"); // Import du module
const FixedBuffer = @import("../main.zig").FixedBuffer;

// Utilisation du type qualifié : EGraph.EClassId
pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("v_{x:0>2}", .{h[0]}),
        .Operation => |op| {
            buf.print("(", .{});
            emit(eg, op.left, buf); // Assure-toi que c'est 'eg' ici
            buf.print(" {s} ", .{getSymbol(op.op)});
            emit(eg, op.right, buf);
            buf.print(")", .{});
        },
        else => buf.print("/* concept complexe */{any}", .{node}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "@dot",
        .Cross => "@cross",
    };
}
