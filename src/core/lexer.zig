const std = @import("std");

pub const TokenKind = enum {
    identifier,
    number,
    plus,     // +
    minus,    // -
    star,     // *
    slash,    // /
    // Opérateurs de structure
    assign,       // :=
    colon,        // :
    arrow,        // ->
    fat_arrow,    // =>
    turnstile,    // |- (Assertion de preuve)
    // Quantificateurs
    kw_forall,    // forall
    kw_from,
    kw_to,
    kw_step,
    kw_exists,    // exists
    // Délimiteurs
    l_paren, r_paren,
    l_bracket, r_bracket,
    eof,
    invalid,
};

pub const Token = struct {
    kind: TokenKind,
    slice: []const u8,
};

pub const Lexer = struct {
    buffer: []const u8,
    pos: usize,

    pub fn init(buffer: []const u8) Lexer {
        return .{ .buffer = buffer, .pos = 0 };
    }

    pub fn tokenize(self: *Lexer, allocator: std.mem.Allocator) ![]Token {
        // Initialisation simple (Unmanaged ne stocke pas l'allocateur)
        var tokens = std.ArrayListUnmanaged(Token){}; 
        // On doit passer l'allocateur au deinit
        errdefer tokens.deinit(allocator);

        while (self.next()) |token| {
            // On passe l'allocateur à chaque opération qui peut allouer
            try tokens.append(allocator, token);
            if (token.kind == .eof) break;
        }
        // toOwnedSlice a aussi besoin de l'allocateur
        return tokens.toOwnedSlice(allocator);
    }

    fn next(self: *Lexer) ?Token {
        self.skipWhitespace();
        if (self.pos >= self.buffer.len) return Token{ .kind = .eof, .slice = "" };

        const start = self.pos;
        const c = self.buffer[self.pos];

        // 1. Détection des symboles multi-caractères
        if (c == ':' and self.peek() == '=') {
            self.pos += 2;
            return Token{ .kind = .assign, .slice = self.buffer[start..self.pos] };
        }
        if (c == '-' and self.peek() == '>') {
            self.pos += 2;
            return Token{ .kind = .arrow, .slice = self.buffer[start..self.pos] };
        }
        if (c == '|' and self.peek() == '-') {
            self.pos += 2;
            return Token{ .kind = .turnstile, .slice = self.buffer[start..self.pos] };
        }

        // 2. Identifiants et Mots-clés
        if (std.ascii.isAlphabetic(c) or c == '_') {
            while (self.pos < self.buffer.len and (std.ascii.isAlphanumeric(self.buffer[self.pos]) or self.buffer[self.pos] == '_')) {
                self.pos += 1;
            }
            const slice = self.buffer[start..self.pos];
            if (std.mem.eql(u8, slice, "forall")) return Token{ .kind = .kw_forall, .slice = slice };
            if (std.mem.eql(u8, slice, "from")) return Token{ .kind = .kw_from, .slice = slice };
            if (std.mem.eql(u8, slice, "to")) return Token{ .kind = .kw_to, .slice = slice };
            if (std.mem.eql(u8, slice, "step")) return Token{ .kind = .kw_step, .slice = slice };
            if (std.mem.eql(u8, slice, "exists")) return Token{ .kind = .kw_exists, .slice = slice };
            return Token{ .kind = .identifier, .slice = slice };
        }

        // 3. Chiffres
        if (std.ascii.isDigit(c)) {
            while (self.pos < self.buffer.len and std.ascii.isDigit(self.buffer[self.pos])) self.pos += 1;
            return Token{ .kind = .number, .slice = self.buffer[start..self.pos] };
        }

        // 4. Symboles simples (LE SWITCH EST ICI)
        self.pos += 1;
        const kind: TokenKind = switch (c) {
            '+' => .plus,
            '-' => .minus,
            '*' => .star,
            '/' => .slash,
            '(' => .l_paren,
            ')' => .r_paren,
            '[' => .l_bracket,
            ']' => .r_bracket,
            ':' => .colon,
            else => .invalid,
        };

        return Token{ .kind = kind, .slice = self.buffer[start..self.pos] };
    }

    fn peek(self: *Lexer) u8 {
        if (self.pos + 1 >= self.buffer.len) return 0;
        return self.buffer[self.pos + 1];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.pos < self.buffer.len and std.ascii.isWhitespace(self.buffer[self.pos])) {
            self.pos += 1;
        }
    }
};
