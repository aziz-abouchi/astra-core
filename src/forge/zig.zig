const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(egraph: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = egraph.nodes[id];
    buf.print("const H = @import(\"heaven.zig\");\nconst std = @import(\"std\");\n\npub fn main() void {s}\n", .{"{"});

    switch (node) {
        .Constant => |val| {
            buf.print("    const result = {d};\n", .{val});
            buf.print("    std.debug.print(\"{s}\\n\", .{{result}});\n", .{"{d}"});
        },
        .Vector => |v| {
            buf.print("    const result = H.Vec3{s} .x = {d}, .y = {d}, .z = {d} {s};\n", .{ "{", v.data[0], v.data[1], v.data[2], "}" });
            buf.print("    H.printVec3(result);\n", .{});
        },
        else => {
            buf.print("    // Opération complexe\n", .{});
        },
    }
    buf.print("{s}\n", .{"}"});
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    var right_is_vec = false;
    if (node == .Operation) right_is_vec = eg.isVector(node.Operation.right);

    switch (node) {
        .Operation => |op| {
            if (op.op == .Mul and right_is_vec) {
                buf.print("H.Vec3.smul(", .{});
                emit(eg, op.left, buf);
                buf.print(", ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" * ", .{}); // Simplifié pour l'exemple
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                const start = std.mem.indexOf(u8, trimmed, "(").?;
                const end = std.mem.lastIndexOf(u8, trimmed, ")").?;

                // On récupère les composants
                var it = std.mem.tokenizeAny(u8, trimmed[start + 1 .. end], ", ");
                const x = it.next() orelse "0";
                const y = it.next() orelse "0";
                const z = it.next() orelse "0";

                buf.print("H.Vec3{{ .x = {s}, .y = {s}, .z = {s} }}", .{ x, y, z });
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Vector => |v| buf.print("H.Vec3{{ .x = {d}, .y = {d}, .z = {d} }}", .{ v.data[0], v.data[1], v.data[2] }),

        .Constant => |val| buf.print("{d}", .{val}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => "@dot",
        .Cross => "@cross",
    };
}
