const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(egraph: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    const node = egraph.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("v_{x:0>2}", .{h[0]}),
        .Operation => |op| {
            // Syntaxe Lean : (a + b) devient un terme formel
            buf.print("(", .{});
            emit(egraph, op.left, buf);
            buf.print(" {s} ", .{if (op.op == .Add) "+" else "*"});
            emit(egraph, op.right, buf);
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
        .Dot => ".", .Cross => "#",
    };
}
