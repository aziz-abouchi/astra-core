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
        .Constant => |val| buf.print("{d}", .{val}),
        .Vector => |v| buf.print("vec3({d}, {d}, {d})", .{v.data[0], v.data[1], v.data[2]}),
        .Atomic => |name| buf.print("{s}", .{name}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "·", .Cross => "×",
    };
}
