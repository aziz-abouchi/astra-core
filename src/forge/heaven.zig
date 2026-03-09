const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const Main = @import("../main.zig");
const FixedBuffer = Main.FixedBuffer;

pub fn emitFull(egraph: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = egraph.nodes[id];
    buf.print("-- Astra Heaven Kernel --\n", .{});
    
    switch (node) {
        .Constant => |val| buf.print("let output = {d}\n", .{val}),
        .Vector => |v| buf.print("let output = vec3({d}, {d}, {d})\n", .{v.data[0], v.data[1], v.data[2]}),
        else => buf.print("let output = complex_node\n", .{}),
    }
    
    buf.print("inspect(output)\n", .{});
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Operation => |op| {
            emit(eg, op.left, buf);
            buf.print(" {s} ", .{getSymbol(op.op)});
            emit(eg, op.right, buf);
        },
        // CORRECTION ICI : Remplace [%g, %g, %g] par [{d}, {d}, {d}]
        .Vector => |v| buf.print("[{d}, {d}, {d}]", .{v.data[0], v.data[1], v.data[2]}),
        .Constant => |val| buf.print("{d}", .{val}),
        .Atomic => |name| buf.print("{s}", .{name}),
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
