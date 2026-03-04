const std = @import("std");
const Parser = @import("../parser.zig");
const Lexer = @import("../lexer.zig");

test "Parser Fact example" {
    const code = "on Fact(0, acc: Int = 1) -> return acc";
    const tokens = Lexer.tokenize(code);
    const ast = Parser.parse(tokens);
    try std.testing.expect(ast.nodes.len > 0);
}
