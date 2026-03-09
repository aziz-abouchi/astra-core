const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("import * as H from '../lib/heaven.js';\n", .{});
    buf.print("const result = ", .{});
    emit(eg, id, buf);
    buf.print(";\nconsole.log(JSON.stringify(result));\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const best_id = eg.getBestId(id);
    const node = eg.nodes[best_id];

    switch (node) {
        .Operation => {
            const op = node.Operation;
            const left_is_vec = eg.isVector(op.left);
            const right_is_vec = eg.isVector(op.right);

            // CAS 1 : Multiplication Scalaire * Vecteur
            if (op.op == .Mul and !left_is_vec and right_is_vec) {
                buf.print("H.smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } 
            // CAS 2 : Addition/Soustraction de Vecteurs
            else if ((op.op == .Add or op.op == .Sub) and left_is_vec and right_is_vec) {
                buf.print("H.vadd(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } 
            // CAS 3 : Opérations scalaires normales (ou erreurs de type)
            else {
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
        .Vector => |v| {
            buf.print("[", .{});
            for (v.data, 0..) |val, i| buf.print("{d}{s}", .{ val, if (i < v.data.len - 1) ", " else "" });
            buf.print("]", .{});
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                // On cherche le contenu entre les premières ( et dernières )
                const start = std.mem.indexOf(u8, trimmed, "(") orelse return buf.print("[]", .{});
                const end = std.mem.lastIndexOf(u8, trimmed, ")") orelse trimmed.len;
                buf.print("[{s}]", .{trimmed[start + 1 .. end]});
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
