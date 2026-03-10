const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const OpType  = @import("../saturation/egraph.zig").OpType;
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    buf.print("import * as H from '../lib/heaven.js';\n", .{});
    buf.print("const result = ", .{});
    emit(eg, id, buf);
    buf.print(";\nconsole.log(JSON.stringify(result));\n", .{});
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const best_id = eg.getBestId(id);
    const node = eg.nodes[best_id];

    switch (node) {
        .Operation => {
            const op = node.Operation;
            const left_is_vec = eg.isVector(op.left);
            const right_is_vec = eg.isVector(op.right);

            if (op.op == .Dot) {
                buf.print("H.fdot(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if (op.op == .Mul and !left_is_vec and right_is_vec) {
                buf.print("H.smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else if ((op.op == .Add or op.op == .Sub) and left_is_vec and right_is_vec) {
                buf.print("H.vadd(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                // Pour les scalaires, on utilise les opérateurs JS standards
                const sym = switch (op.op) {
                    .Add => "+",
                    .Sub => "-",
                    .Mul => "*",
                    .Div => "/",
                    // Sécurité : si un reliquat de Dot ou Cross arrive ici
                    .Dot => "*", 
                    else => "+", 
                };
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{sym});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Scalar => |val| {
            // Utilisation de {d} pour éviter la notation scientifique que JS pourrait mal parser si trop longue
            buf.print("{d}", .{val.value});
        },
        .Vector => |v| {
            buf.print("[", .{});
            for (v.data, 0..) |val, i| {
                buf.print("{d}{s}", .{ val.value, if (i < v.data.len - 1) ", " else "" });
            }
            buf.print("]", .{});
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " \n\r\t");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                const start = std.mem.indexOf(u8, trimmed, "(") orelse return buf.print("[]", .{});
                const end = std.mem.lastIndexOf(u8, trimmed, ")") orelse trimmed.len;
                buf.print("[{s}]", .{trimmed[start + 1 .. end]});
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Hole => {
            buf.print("null", .{}); // En JS, un trou est un null
        },
    }
}

fn getSymbol(op: OpType, is_vector: bool) []const u8 {
    return switch (op) {
        .Add => if (is_vector) "vadd" else "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "fdot",
        .Cross => "fcross",
    };
}
