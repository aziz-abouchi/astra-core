const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

// 1. Définition explicite des erreurs pour briser la récursion
pub const ParseError = error{
    EndOfStream,
    InvalidInput,
    UnbalancedParenthesis,
    OutOfMemory, // addNode peut échouer
};

pub fn parse(allocator: std.mem.Allocator, eg: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    var tokens = std.mem.tokenizeAny(u8, input, " ");
    return try parseExpr(&tokens, eg, 0);
}

// 2. Utilise ParseError ici
fn parseExpr(tokens: *std.mem.TokenIterator(u8, .any), eg: *EGraph.EGraph, min_prec: u8) ParseError!EGraph.EClassId {
    var lhs = try parseLeaf(tokens, eg);

    while (true) {
        const checkpoint = tokens.index;
        const op_token = tokens.next() orelse break;
        
        const op_type = getOpType(op_token) orelse {
            tokens.index = checkpoint;
            break;
        };

        const prec = getPrecedence(op_type);
        if (prec < min_prec) {
            tokens.index = checkpoint;
            break;
        }

        const rhs = try parseExpr(tokens, eg, prec + 1);
        lhs = eg.addNode(.{ .Operation = .{ .op = op_type, .left = lhs, .right = rhs } }) catch return error.OutOfMemory;
    }

    return lhs;
}

// 3. Et ici aussi
fn parseLeaf(tokens: *std.mem.TokenIterator(u8, .any), eg: *EGraph.EGraph) ParseError!EGraph.EClassId {
    const token = tokens.next() orelse return error.EndOfStream;

    if (std.mem.eql(u8, token, "(")) {
        const id = try parseExpr(tokens, eg, 0);
        const next = tokens.next() orelse return error.UnbalancedParenthesis;
        if (!std.mem.eql(u8, next, ")")) return error.UnbalancedParenthesis;
        return id;
    }

    if (std.fmt.parseFloat(f64, token)) |val| {
        return eg.addNode(.{ .Constant = val }) catch return error.OutOfMemory;
    } else |_| {
        var buf = [_]u8{' '} ** 32;
        const len = @min(token.len, 32);
        @memcpy(buf[0..len], token[0..len]);
        return eg.addNode(.{ .Atomic = buf }) catch return error.OutOfMemory;
    }
}

fn getOpType(token: []const u8) ?EGraph.OpType {
    if (std.mem.eql(u8, token, "+")) return .Add;
    if (std.mem.eql(u8, token, "-")) return .Sub;
    if (std.mem.eql(u8, token, "*")) return .Mul;
    if (std.mem.eql(u8, token, "/")) return .Div;
    if (std.mem.eql(u8, token, ".")) return .Dot;
    if (std.mem.eql(u8, token, "#")) return .Cross;
    return null;
}

fn getPrecedence(op: EGraph.OpType) u8 {
    return switch (op) {
        .Add, .Sub => 1,
        .Mul, .Div => 2,
        .Dot, .Cross => 3, // Priorité haute pour les vecteurs
    };
}
