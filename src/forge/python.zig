const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("import lib.heaven as H\n", .{});
    buf.print("result = ", .{});
    emit(eg, id, buf);
    buf.print("\nprint(result)\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    
    var left_is_vec = false;
    var right_is_vec = false;
    if (node == .Operation) {
        left_is_vec = eg.isVector(node.Operation.left);
        right_is_vec = eg.isVector(node.Operation.right);
    }

    switch (node) {
        .Operation => |op| {
            const sym = getSymbol(op.op);

            if (op.op == .Mul and !left_is_vec and right_is_vec) {
                buf.print("H.smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if (op.op == .Dot) { // AJOUT ICI
                buf.print("H.dot(", .{}); 
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if (op.op == .Cross) { // AJOUT ICI
                buf.print("H.cross(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if (op.op == .Add and (left_is_vec or right_is_vec)) { // Simplifié ici
                buf.print("H.vadd(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{sym});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                const start = std.mem.indexOf(u8, trimmed, "(").?;
                const end = std.mem.lastIndexOf(u8, trimmed, ")").?;
                buf.print("[{s}]", .{trimmed[start + 1 .. end]});
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Scalar => |val| buf.print("{d}", .{val.toF64()}),
        .Vector => |v| {
            buf.print("[", .{});
            for (v.data, 0..) |val, i| buf.print("{d}{s}", .{ val.toF64(), if (i < v.data.len - 1) ", " else "" });
            buf.print("]", .{});
        },
        .Hole => {
            buf.print("???", .{}); // Ou une représentation visuelle d'un trou
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
