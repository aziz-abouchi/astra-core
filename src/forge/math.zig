const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");
const FixedBuffer = Main.FixedBuffer;

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Operation => |op| {
            buf.print("(", .{});
            emit(eg, op.left, buf);
            buf.print(" {s} ", .{getSymbol(op.op)});
            emit(eg, op.right, buf);
            buf.print(")", .{});
        },
        .Scalar => |val| buf.print("{d}", .{val.toF64()}),
        .Vector => |v| buf.print("vec3({d}, {d}, {d})", .{v.data[0].toF64(), v.data[1].toF64(), v.data[2].toF64()}),
        .Atomic => |name| buf.print("{s}", .{name}),
        .Hole => {
            buf.print("???", .{}); // Ou une représentation visuelle d'un trou
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "·", .Cross => "×",
    };
}
