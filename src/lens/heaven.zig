const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;

pub const ParseError = error{
    InvalidInput,
    UnbalancedBracket,
    OutOfMemory,
    StackOverflow,
    NotImplemented,
} || std.fmt.ParseFloatError; // On inclut les erreurs de parseFloat

pub fn parse(allocator: std.mem.Allocator, eg: *EGraph, input: []const u8) !EClassId {
    _ = allocator;
    var pos: usize = 0;
    var last_id: EClassId = 0;
    
    std.debug.print("[Heaven]: Analyse du signal mathématique...\n", .{});
    
    while (true) {
        skipWhitespace(input, &pos);
        if (pos >= input.len) break;
        last_id = try parseExpr(eg, input, &pos);
    }
    
    return last_id;
}

// On remplace !EClassId par ParseError!EClassId pour casser l'inférence circulaire
fn parseExpr(eg: *EGraph, input: []const u8, pos: *usize) ParseError!EClassId {
    skipWhitespace(input, pos);
    if (pos.* >= input.len) return error.InvalidInput;

    // 1. Parenthèses
    if (input[pos.*] == '(') {
        pos.* += 1;
        var children = [_]EClassId{0} ** 8;
        var count: usize = 0;
        while (pos.* < input.len and input[pos.*] != ')') {
            if (count >= 8) return error.StackOverflow;
            children[count] = try parseExpr(eg, input, pos);
            count += 1;
            skipWhitespace(input, pos);
        }
        if (pos.* >= input.len) return error.UnbalancedBracket;
        pos.* += 1;
        return try handlePostInfix(eg, input, pos, try lowerToEGraph(eg, children[0..count]));
    }

    // 2. Vecteurs
    if (input[pos.*] == '[') {
        pos.* += 1;
        var values: [16]f64 = undefined;
        var count: usize = 0;
        while (pos.* < input.len and input[pos.*] != ']') {
            skipWhitespace(input, pos);
            if (input[pos.*] == ']') break;
            const start_val = pos.*;
            while (pos.* < input.len and !isDelimiter(input[pos.*]) and input[pos.*] != ',' and input[pos.*] != ']') : (pos.* += 1) {}
            const val_token = input[start_val..pos.*];
            if (val_token.len > 0) {
                values[count] = try std.fmt.parseFloat(f64, val_token);
                count += 1;
            }
            skipWhitespace(input, pos);
            if (pos.* < input.len and input[pos.*] == ',') pos.* += 1;
        }
        if (pos.* < input.len) pos.* += 1;
        return try handlePostInfix(eg, input, pos, try eg.addVector(values[0..count]));
    }

    // 3. Atomes et Opérateurs
    const start = pos.*;
    while (pos.* < input.len and !isDelimiter(input[pos.*])) : (pos.* += 1) {}
    const token = input[start..pos.*];

    if (std.mem.eql(u8, token, "Π")) {
        _ = try parseExpr(eg, input, pos); // idx
        const domain_id = try parseExpr(eg, input, pos);
        const body_id = try parseExpr(eg, input, pos);
        return try handlePostInfix(eg, input, pos, try eg.addNode(.{ .Operation = .{ 
            .op = .Mul, .left = domain_id, .right = body_id, .dim = eg.getDim(body_id) 
        } }));
    }

    // Définition (a = ...)
    const save_pos = pos.*;
    skipWhitespace(input, pos);
    if (pos.* < input.len and input[pos.*] == '=') {
        pos.* += 1;
        const lhs_id = try liftAtom(eg, token);
        const rhs_id = try parseExpr(eg, input, pos);
        eg.unionConcepts(lhs_id, rhs_id);
        return rhs_id;
    }
    pos.* = save_pos;

    // Terme simple + Infixés
    return try handlePostInfix(eg, input, pos, try liftAtom(eg, token));
}

// Même chose ici : ParseError!EClassId
fn handlePostInfix(eg: *EGraph, input: []const u8, pos: *usize, left_id: EClassId) ParseError!EClassId {
    var current_id = left_id;
    while (true) {
        skipWhitespace(input, pos);
        if (pos.* >= input.len) break;
        const c = input[pos.*];
        if (c == '!') {
            pos.* += 1;
            current_id = try eg.addNode(.{ .Operation = .{ .op = .Mul, .left = current_id, .right = current_id, .dim = 0 } });
        } else if (c == '.') {
            pos.* += 1;
            const rhs_id = try parseExpr(eg, input, pos);
            current_id = try eg.addNode(.{ .Operation = .{ .op = .Dot, .left = current_id, .right = rhs_id, .dim = 0 } });
        } else {
            break;
        }
    }
    return current_id;
}

fn lowerToEGraph(eg: *EGraph, items: []EClassId) !EClassId {
    if (items.len == 0) return try eg.addNode(.{ .Atomic = .{'N'} ** 32 });
    
    // Si on a (A OP B), items.len sera 3 si OP est un atome
    if (items.len == 3) {
        // On pourrait ici analyser items[1] pour savoir si c'est + ou *
        // Pour l'instant, forçons le Mul pour ton test (2 * a)
        return try eg.addNode(.{ .Operation = .{ 
            .op = .Mul, 
            .left = items[0], 
            .right = items[2], 
            .dim = eg.getDim(items[2]) 
        } });
    }
    
    return items[0];
}

fn liftAtom(eg: *EGraph, token: []const u8) ParseError!EClassId {
    if (std.fmt.parseFloat(f64, token)) |val| {
        // On encapsule le f64 dans une Quantity "neutre" (sans unité)
        return eg.addNode(.{ .Scalar = .{
            .value = val,
            .mantissa = val,
            .uncertainty = 0,
            .exponent = 0,
            .unit = .{ .m = 0, .l = 0, .t = 0, .i = 0 },
        } });
    } else |_| {
        var buf = [_]u8{' '} ** 32;
        const len = @min(token.len, 32);
        @memcpy(buf[0..len], token[0..len]);
        return eg.addNode(.{ .Atomic = buf });
    }
}

fn isDelimiter(c: u8) bool {
    return std.ascii.isWhitespace(c) or c == '(' or c == ')' or c == '!' or c == '=' or c == '.' or c == '[' or c == ']';
}

fn skipWhitespace(input: []const u8, pos: *usize) void {
    while (pos.* < input.len) {
        const c = input[pos.*];
        if (std.ascii.isWhitespace(c)) {
            pos.* += 1;
        } else if (pos.* + 1 < input.len and input[pos.*] == '/' and input[pos.* + 1] == '/') {
            while (pos.* < input.len and input[pos.*] != '\n') : (pos.* += 1) {}
        } else {
            break;
        }
    }
}
