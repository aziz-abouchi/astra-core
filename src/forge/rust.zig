const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("fn main() {{\n", .{});
    // On pourrait injecter une mini-lib ici, ou juste émettre le calcul direct
    buf.print("    let result = ", .{});
    emit(eg, id, buf);
    buf.print(";\n    println!(\"{{:?}}\", result);\n", .{});
    buf.print("}}\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    var right_is_vec = false;
    if (node == .Operation) right_is_vec = eg.isVector(node.Operation.right);

    switch (node) {
        .Operation => |op| {
            if (op.op == .Mul and right_is_vec) {
                buf.print("{{ let s = ", .{});
                emit(eg, op.left, buf);
                buf.print("; let v = ", .{});
                emit(eg, op.right, buf);
                buf.print("; [v[0] * s, v[1] * s, v[2] * s] }}", .{});
            } else {
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{getSymbol(op.op)});
                emit(eg, op.right, buf);
            }
        },
        .Constant => |val| buf.print("{d}_f64", .{val}),
        .Vector => |v| buf.print("[{d}_f64, {d}_f64, {d}_f64]", .{ v.data[0], v.data[1], v.data[2] }),
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                // On transforme vec3(1,2,3) en [1.0, 2.0, 3.0]
                const start = std.mem.indexOf(u8, trimmed, "(").?;
                const end = std.mem.lastIndexOf(u8, trimmed, ")").?;
                var it = std.mem.tokenizeAny(u8, trimmed[start + 1 .. end], ", ");
                buf.print("[", .{});
                var first = true;
                while (it.next()) |val| {
                    if (!first) buf.print(", ", .{});
                    buf.print("{s}_f64", .{val});
                    first = false;
                }
                buf.print("]", .{});
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "vadd",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "fdot",
        .Cross => "fcross",
    };
}
