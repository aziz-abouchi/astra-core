const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("# --- Astra Python Runtime ---\n", .{});
    // Définition de l'addition vectorielle
    buf.print("def vadd(u, v): return [a + b for a, b in zip(u, v)]\n", .{});
    // Définition du produit scalaire (dot)
    buf.print("def fdot(u, v): return sum(a * b for a, b in zip(u, v))\n", .{});
    // Définition du produit vectoriel (cross)
    buf.print("def fcross(u, v):\n", .{});
    buf.print("    return [\n", .{});
    buf.print("        u[1]*v[2] - u[2]*v[1],\n", .{});
    buf.print("        u[2]*v[0] - u[0]*v[2],\n", .{});
    buf.print("        u[0]*v[1] - u[1]*v[0]\n", .{});
    buf.print("    ]\n\n", .{});

    buf.print("result = ", .{});
    emit(eg, id, buf);
    buf.print("\nprint(result)\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Operation => |op| {
            const sym = getSymbol(op.op);
            if (std.mem.eql(u8, sym, "vadd") or std.mem.eql(u8, sym, "fdot") or std.mem.eql(u8, sym, "fcross")) {
                buf.print("{s}(", .{sym});
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
                buf.print("[{s}]", .{trimmed[5..trimmed.len-1]});
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Constant => |val| buf.print("{d}", .{val}),
        .Vector => |v| buf.print("[{d}, {d}, {d}]", .{v.x, v.y, v.z}),
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
