const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const ast = @import("ast.zig");

pub fn parse(allocator: std.mem.Allocator, source: []const u8) !*ast.Node {
    var l = lexer.Lexer.init(source);
    const tokens = try l.tokenize(allocator);
    defer allocator.free(tokens);
    var p = parser.Parser.init(allocator, tokens);
    return p.parse();
}

pub fn unify(node: *ast.Node) !void { _ = node; }

pub fn generateDoc(allocator: std.mem.Allocator, node: *ast.Node) ![]const u8 {
    var out = std.ArrayListUnmanaged(u8){};
    errdefer out.deinit(allocator);
    
    try out.appendSlice(allocator, "graph TD\n");
    var counter: usize = 0;
    try walkMermaid(allocator, node, &out, null, &counter);
    return out.toOwnedSlice(allocator);
}

fn walkMermaid(allocator: std.mem.Allocator, node: *ast.Node, out: *std.ArrayListUnmanaged(u8), parent_id: ?usize, counter: *usize) anyerror!void {
    const id = counter.*;
    counter.* += 1;
    
    try out.writer(allocator).print("  n{d}[\"{s}\"]\n", .{ id, node.kindToString() });
    if (parent_id) |pid| try out.writer(allocator).print("  n{d} --> n{d}\n", .{ pid, id });

    switch (node.kind) {
        .program => {
            for (node.data.list) |child| {
                try walkMermaid(allocator, child, out, id, counter);
            }
        },
        .forall => {
            for (node.data.forall.vars) |variable| try walkMermaid(allocator, variable, out, id, counter);
            if (node.data.forall.domain) |dom| try walkMermaid(allocator, dom, out, id, counter);
            try walkMermaid(allocator, node.data.forall.body, out, id, counter);
        },
        .comparison, .equation => {
            try walkMermaid(allocator, node.data.binary.left, out, id, counter);
            try walkMermaid(allocator, node.data.binary.right, out, id, counter);
        },
        .factorial => try walkMermaid(allocator, node.data.unary, out, id, counter),
        .access => {
            try walkMermaid(allocator, node.data.access.array, out, id, counter);
            try walkMermaid(allocator, node.data.access.index, out, id, counter);
        },
        .set => {
            for (node.data.list) |item| try walkMermaid(allocator, item, out, id, counter);
        },
        else => {},
    }
}
