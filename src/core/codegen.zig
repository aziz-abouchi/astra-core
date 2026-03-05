const std = @import("std");
const ast = @import("ast.zig");

pub const Target = enum { fortran, forth, heaven };

pub fn generate(allocator: std.mem.Allocator, node: *ast.Node, target: Target) ![]const u8 {
    var out = std.ArrayList(u8).init(allocator);
    errdefer out.deinit();

    try visit(node, &out, target);
    return out.toOwnedSlice();
}

fn visit(node: *ast.Node, out: *std.ArrayList(u8), target: Target) !void {
    switch (node.kind) {
        .constant, .identifier, .domain => try out.writer().print("{s} ", .{node.data.string}),
        
        .factorial => {
            if (target == .forth) {
                try visit(node.data.unary, out, target);
                try out.writer().print("FACT ", .{});
            } else {
                try out.writer().print("factorial(", .{});
                try visit(node.data.unary, out, target);
                try out.writer().print(")", .{});
            }
        },

        .comparison => {
            const op = node.data.binary.op;
            if (target == .forth) {
                try visit(node.data.binary.left, out, target);
                try visit(node.data.binary.right, out, target);
                try out.writer().print("{s} ", .{if (op == .geq) ">=" else "=="});
            } else if (target == .fortran) {
                try visit(node.data.binary.left, out, target);
                try out.writer().print(" .{s}. ", .{if (op == .geq) "GE" else "EQ"});
                try visit(node.data.binary.right, out, target);
            }
        },
        
        .forall => {
            // Heaven : Syntaxe purement logique
            if (target == .heaven) {
                try out.writer().print("⟨Heaven::forall {s} in ", .{node.data.forall.variable.data.string});
                try visit(node.data.forall.domain, out, target);
                try out.writer().print("⊢ ", .{});
                try visit(node.data.forall.body, out, target);
                try out.writer().print("⟩", .{});
            } else {
                // Pour Fortran/Forth, on génère souvent une boucle ou une assertion
                try visit(node.data.forall.body, out, target);
            }
        },
        else => {},
    }
}
