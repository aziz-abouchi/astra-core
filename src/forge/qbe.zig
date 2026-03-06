const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(egraph: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    const node = egraph.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("%%v_{x:0>2}", .{h[0]}),
        .Operation => |op| {
            buf.print("(", .{});
            const instr = if (op.op == .Add) "add" else "mul";
            buf.print("{s} w ", .{instr}); // 'w' pour word/32-bit
            emit(egraph, op.left, buf);
            buf.print(", ", .{});
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
