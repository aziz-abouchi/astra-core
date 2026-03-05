const std = @import("std");

pub const TokenKind = enum {
    identifier,
    number,
    plus,     // +
    minus,    // -
    star,     // *
    slash,    // /
    pipe,     // |
    // Opérateurs de structure
    assign,       // :=
    colon,        // :
    comma,        // ,
    arrow,        // ->
    fat_arrow,    // =>
    turnstile,    // |- (Assertion de preuve)
    // Quantificateurs
    kw_forall,    // forall
    kw_from,
    kw_to,
    kw_step,
    kw_exists,    // exists
    in_sym,
    pi_sym,      // π
    geq, leq, equal,
    bang,
    domain_nat, domain_nat_star,
    // Délimiteurs
    l_paren, r_paren, l_bracket, r_bracket, l_brace, r_brace,
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
        const remaining = self.buffer[self.pos..];

        // 1. Détection des symboles Unicode (Multi-octets)
        if (std.mem.startsWith(u8, remaining, "∀")) {
            self.pos += 3; // '∀' fait 3 octets en UTF-8
            return Token{ .kind = .kw_forall, .slice = self.buffer[start..self.pos] };
        }
        if (std.mem.startsWith(u8, remaining, "∈")) {
            self.pos += 3;
            return Token{ .kind = .in_sym, .slice = self.buffer[start..self.pos] };
        }
        if (std.mem.startsWith(u8, remaining, "≥")) {
            self.pos += 3;
            return Token{ .kind = .geq, .slice = self.buffer[start..self.pos] };
        }
        if (std.mem.startsWith(u8, remaining, "ℕ")) {
            self.pos += 3;
            if (self.pos < self.buffer.len and self.buffer[self.pos] == '*') {
                self.pos += 1;
                return Token{ .kind = .domain_nat_star, .slice = self.buffer[start..self.pos] };
            }
            return Token{ .kind = .domain_nat, .slice = self.buffer[start..self.pos] };
        }
        if (std.mem.startsWith(u8, remaining, "π")) {
            self.pos += "π".len;
            return .{ .kind = .pi_sym, .slice = self.buffer[start..self.pos] };
        }

        const c = self.buffer[self.pos];

        // 2. Identifiants et Mots-clés (inchangé)
        if (std.ascii.isAlphabetic(c) or c == '_') {
            while (self.pos < self.buffer.len and (std.ascii.isAlphanumeric(self.buffer[self.pos]) or self.buffer[self.pos] == '_')) {
                self.pos += 1;
            }
            return Token{ .kind = .identifier, .slice = self.buffer[start..self.pos] };
        }

        // 3. Chiffres (Correction isDigit)
        if (std.ascii.isDigit(c)) {
            return self.scanNumber();
        }

        // 4. Symboles ASCII simples
        self.pos += 1;
        const kind: TokenKind = switch (c) {
            '+' => .plus,
            '-' => .minus,
            '*' => .star,
            '/' => .slash,
            '|' => .pipe,
            '=' => .equal,
            '(' => .l_paren,
            ')' => .r_paren,
            '[' => .l_bracket,
            ']' => .r_bracket,
            '{' => .l_brace,
            '}' => .r_brace,
            ':' => .colon,
            ',' => .comma,
            '!' => .bang,
            else => .invalid,
        };
        return self.makeToken(kind, start);
    }

    fn scanNumber(self: *Lexer) Token {
        const start = self.pos;
        var has_dot = false;
        while (self.pos < self.buffer.len) {
            const c = self.buffer[self.pos];
            if (std.ascii.isDigit(c)) {
                self.pos += 1;
            } else if (c == '.' and !has_dot) {
                has_dot = true;
                self.pos += 1;
            } else break;
        }
        return self.makeToken(.number, start);
    }

    fn peek(self: *Lexer) u8 {
        if (self.pos >= self.buffer.len) return 0;
        return self.buffer[self.pos];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.pos < self.buffer.len and std.ascii.isWhitespace(self.buffer[self.pos])) {
            self.pos += 1;
        }
    }

    fn makeToken(self: *Lexer, kind: TokenKind, start: usize) Token {
        return Token{ .kind = kind, .slice = self.buffer[start..self.pos] };
    }

};
