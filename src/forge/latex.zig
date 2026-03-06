const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("x_{{{x:0>2}}}", .{h[0]}),
        .Operation => |op| {
            if (op.op == .Mul) {
                emit(eg, op.left, buf);
                buf.print(" \\cdot ", .{});
                emit(eg, op.right, buf);
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" + ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
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
        .Dot => ".", .Cross => "#",
    };
}
