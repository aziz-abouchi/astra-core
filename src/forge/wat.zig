const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(egraph: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    const node = egraph.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("  local.get $v_{x:0>2}\n", .{h[0]}),
        .Operation => |op| {
            // Postfixé : on pousse les enfants sur la pile WASM
            emit(egraph, op.left, buf);
            emit(egraph, op.right, buf);
            const op_code = if (op.op == .Add) "f64.add" else "f64.mul";
            buf.print("  {s}\n", .{op_code});
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
