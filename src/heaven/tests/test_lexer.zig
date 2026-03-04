const std = @import("std");
const Lexer = @import("../lexer.zig");

test "Lexer tokenize Fact example" {
    const code = "on Fact(0, acc: Int = 1) -> return acc";
    const tokens = Lexer.tokenize(code);
    try std.testing.expect(tokens.len > 0);
}
