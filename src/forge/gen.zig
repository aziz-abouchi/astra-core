const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn emitZig(egraph: *EGraph, id: EGraph.EClassId, writer: anytype) !void {
    const node = egraph.nodes[id];
    switch (node) {
        .Scalar => |val| {
            try writer.print("{d}", .{val.toF64()});
        },
        .Vector => |vec| {
            try writer.print("[", .{});
            for (vec.data, 0..) |val, i| {
                try writer.print("{d}", .{val.toF64()});
                if (i < vec.data.len - 1) try writer.print(", ", .{});
            }
            try writer.print("]", .{}); // Correction du crochet ici !
        },
        .Atomic => |h| {
            // On nettoie le nom de l'atome (enlever les espaces du buffer fixe)
            const name = std.mem.trim(u8, &h, " ");
            try writer.print("{s}", .{name}); 
        },
        .Operation => |op| {
            try writer.print("(", .{});
            try emitZig(egraph, op.left, writer);
            try writer.print(" {s} ", .{getSymbol(op.op)});
            try emitZig(egraph, op.right, writer);
            try writer.print(")", .{});
        },
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
