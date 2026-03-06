const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("// --- Astra JS Runtime ---\n", .{});
    buf.print("const smul = (s, v) => v.map(x => s * x);\n", .{});
    buf.print("const result = ", .{});
    emit(eg, id, buf);
    buf.print(";\nconsole.log(result);\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const best_id = eg.getBestId(id);
    const node = eg.nodes[best_id];

    switch (node) {
        .Operation => { 
            // On s'assure qu'on traite bien une opération
            const op = node.Operation; 

            const left_is_vec = eg.isVector(op.left);
            const right_is_vec = eg.isVector(op.right);

            if (op.op == .Mul and !left_is_vec and right_is_vec) {
                buf.print("smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if ((op.op == .Add or op.op == .Sub) and (left_is_vec or right_is_vec)) {
                buf.print("vadd(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                const sym = switch (op.op) {
                    .Add => "+",
                    .Sub => "-",
                    .Mul => "*",
                    .Div => "/",
                    else => "?",
                };
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{sym});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Constant => |val| buf.print("{d}", .{val}),
        .Vector => |v| buf.print("[{d}, {d}, {d}]", .{v.x, v.y, v.z}),
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            // Si c'est un vec3 brut, on le transforme en tableau JS
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                buf.print("[{s}]", .{trimmed[5..trimmed.len-1]});
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
    }
}

fn getSymbol(op: EGraph.OpType, is_vector: bool) []const u8 {
    return switch (op) {
        .Add => if (is_vector) "vadd" else "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "fdot",
        .Cross => "fcross",
    };
}
