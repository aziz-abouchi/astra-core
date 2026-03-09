const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub const ParseError = error{
    EndOfStream,
    InvalidInput,
    UnbalancedParenthesis,
    OutOfMemory,
};

// On définit ce qui est un délimiteur
fn isDelim(c: u8) bool {
    return switch (c) {
        '(', ')', '+', '-', '*', '/', '.', '#', ',', ' ', '\t', '\n', '\r' => true,
        else => false,
    };
}

pub fn parse(allocator: std.mem.Allocator, eg: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    var pos: usize = 0;
    return try parseExpr(input, &pos, eg, 0);
}

fn nextToken(input: []const u8, pos: *usize) ?[]const u8 {
    while (pos.* < input.len and std.ascii.isWhitespace(input[pos.*])) : (pos.* += 1) {}
    if (pos.* >= input.len) return null;

    const start = pos.*;
    const c = input[start];

    // Si c'est un délimiteur (opérateur ou parenthèse), on le renvoie TOUJOURS seul
    if (isDelim(c)) {
        pos.* += 1;
        return input[start..pos.*];
    }

    // Sinon, c'est un mot (nombre ou nom d'atome comme 'vec3')
    // On s'arrête dès qu'on voit n'importe quel délimiteur
    while (pos.* < input.len and !isDelim(input[pos.*])) : (pos.* += 1) {}
    return input[start..pos.*];
}

fn parseExpr(input: []const u8, pos: *usize, eg: *EGraph.EGraph, min_prec: u8) ParseError!EGraph.EClassId {
    var lhs = try parseLeaf(input, pos, eg);

    while (true) {
        const start_pos = pos.*;
        const op_token = nextToken(input, pos) orelse break;
        
        const op_type = getOpType(op_token) orelse {
            pos.* = start_pos; // On rembobine si ce n'est pas un opérateur
            break;
        };

        const prec = getPrecedence(op_type);
        if (prec < min_prec) {
            pos.* = start_pos;
            break;
        }

        const rhs = try parseExpr(input, pos, eg, prec + 1);
        lhs = eg.addNode(.{ .Operation = .{ .op = op_type, .left = lhs, .right = rhs } }) catch return error.OutOfMemory;
    }

    return lhs;
}

fn parseLeaf(input: []const u8, pos: *usize, eg: *EGraph.EGraph) ParseError!EGraph.EClassId {
    const token = nextToken(input, pos) orelse return error.EndOfStream;

    // 1. Parenthèses classiques
    if (std.mem.eql(u8, token, "(")) {
        const id = try parseExpr(input, pos, eg, 0);
        const next = nextToken(input, pos) orelse return error.UnbalancedParenthesis;
        if (!std.mem.eql(u8, next, ")")) return error.UnbalancedParenthesis;
        return id;
    }

    // 2. Détection du vecteur structuré "vec3(x, y, z)"
    if (std.mem.eql(u8, token, "vec3")) {
        const next = nextToken(input, pos) orelse return error.InvalidInput;
        if (std.mem.eql(u8, next, "(")) {
            return try parseVector(input, pos, eg);
        }
        // Si c'est juste le mot "vec3" sans parenthèse, on tombe dans le cas Atomic
    }

    // 3. Nombres constants
    if (std.fmt.parseFloat(f64, token)) |val| {
        return eg.addNode(.{ .Constant = val }) catch return error.OutOfMemory;
    } else |_| {
        // 4. Atomes divers
        var buf = [_]u8{' '} ** 32;
        const len = @min(token.len, 32);
        @memcpy(buf[0..len], token[0..len]);
        return eg.addNode(.{ .Atomic = buf }) catch return error.OutOfMemory;
    }
}

fn parseVector(input: []const u8, pos: *usize, eg: *EGraph.EGraph) ParseError!EGraph.EClassId {
    var coords = [_]f64{ 0, 0, 0 };
    var i: usize = 0;

    while (i < 3) {
        const token = nextToken(input, pos) orelse return error.InvalidInput;
        
        // On saute les virgules silencieusement
        if (std.mem.eql(u8, token, ",")) continue;
        
        // On parse le nombre. Si ça échoue, c'est une erreur d'entrée.
        coords[i] = std.fmt.parseFloat(f64, token) catch {
            return error.InvalidInput;
        };
        
        i += 1;
    }

    // On s'attend à la parenthèse fermante
    const last = nextToken(input, pos) orelse return error.UnbalancedParenthesis;
    
    // Petite tolérance : si on a une virgule traînante vec3(1,2,3,)
    if (std.mem.eql(u8, last, ",")) {
        const true_last = nextToken(input, pos) orelse return error.UnbalancedParenthesis;
        if (!std.mem.eql(u8, true_last, ")")) return error.UnbalancedParenthesis;
    } else if (!std.mem.eql(u8, last, ")")) {
        return error.UnbalancedParenthesis;
    }

    return eg.addNode(.{ .Vector = .{ .x = coords[0], .y = coords[1], .z = coords[2] } }) catch return error.OutOfMemory;
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

