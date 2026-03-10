const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(egraph: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const best_id = egraph.getBestId(id);
    const node = egraph.nodes[best_id];
    
    buf.print("#include \"../lib/heaven.h\"\n\nint main() {s}\n", .{"{"});

    switch (node) {
        .Scalar => |val| {
            buf.print("    double result = {d};\n", .{val.toF64()});
            buf.print("    printf(\"%f\\n\", result);\n", .{});
        },
        .Vector => |v| {
            const dim = v.data.len;
            buf.print("    double result[{d}] = {s}", .{dim, "{"});
            for (v.data, 0..) |val, i| {
                buf.print("{d}{s}", .{val.toF64(), if (i < dim - 1) ", " else ""});
            }
            buf.print("{s};\n", .{"}"});
            buf.print("    // Print logic for vecN here\n", .{});
        },
        else => {
            buf.print("    // Calcul complexe optimisé par GUPI\n", .{});
        }
    }
    buf.print("    return 0;\n{s}\n", .{"}"});
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    
    var left_is_vec = false;
    var right_is_vec = false;
    if (node == .Operation) {
        left_is_vec = eg.isVector(node.Operation.left);
        right_is_vec = eg.isVector(node.Operation.right);
    }

    switch (node) {
        .Operation => |op| {
            if (op.op == .Mul and !left_is_vec and right_is_vec) {
                buf.print("smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" {s} ", .{getSymbol(op.op)});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                const start = std.mem.indexOf(u8, trimmed, "(").?;
                const end = std.mem.lastIndexOf(u8, trimmed, ")").?;
                // Injection safe de l'accolade pour le cast C
                buf.print("((vec3){s}{s}{s})", .{ "{", trimmed[start + 1 .. end], "}" });
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Scalar => |val| buf.print("{d}", .{val.toF64()}),
        .Vector => |v| buf.print("((vec3){s}{d}, {d}, {d}{s})", .{ "{", v.data[0].toF64(), v.data[1].toF64(), v.data[2].toF64(), "}" }),
    }
}

fn getSymbol(op: @import("../saturation/egraph.zig").OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "dot",
        .Cross => "cross",
    };
}
