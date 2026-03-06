const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("// --- Astra Rust Runtime ---\n", .{});
    buf.print("type Vec3 = [f64; 3];\n\n", .{});
    
    // On utilise {s} pour injecter les accolades proprement
    buf.print("fn vadd(u: Vec3, v: Vec3) -> Vec3 {s} [u[0]+v[0], u[1]+v[1], u[2]+v[2]] {s}\n", .{ "{", "}" });
    buf.print("fn fdot(u: Vec3, v: Vec3) -> f64 {s} u[0]*v[0] + u[1]*v[1] + u[2]*v[2] {s}\n", .{ "{", "}" });
    
    buf.print("fn fcross(u: Vec3, v: Vec3) -> Vec3 {s}\n", .{"{"});
    buf.print("    [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]\n", .{});
    buf.print("{s}\n\n", .{"}"});

    buf.print("fn main() {s}\n", .{"{"});
    buf.print("    let result = ", .{});
    emit(eg, id, buf);
    buf.print(";\n", .{});
    
    // Ici on injecte le formatage Rust {:?} via une string pour que Zig ne dise rien
    buf.print("    println!(\"{s}\", result);\n", .{"{:?}"}); 
    buf.print("{s}\n", .{"}"});
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
        .Constant => |val| buf.print("{d}.0", .{val}), // Rust est strict sur les floats
        .Vector => |v| buf.print("[{d}.0, {d}.0, {d}.0]", .{v.x, v.y, v.z}),
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
