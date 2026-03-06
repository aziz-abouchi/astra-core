const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("v_{x:0>2}", .{h[0]}),
        .Operation => |op| {
            buf.print("(", .{});
            emit(eg, op.left, buf);
            buf.print(" {s} ", .{if (op.op == .Add) "+" else "*"});
            emit(eg, op.right, buf);
            buf.print(")", .{});
        },
        else => buf.print("/* concept complexe */{any}", .{node}),
    }
}
// Note : Le "fun calc" doit être ajouté par le main.zig autour de l'appel

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => ".", .Cross => "#",
    };
}
