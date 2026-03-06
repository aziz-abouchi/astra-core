const std = @import("std");
const lexer = @import("lexer.zig");

pub fn parseToRPN(input: []const u8, output: []lexer.Token) usize {
    var lex = lexer.Lexer{ .buffer = input };
    var ops_stack: [16]lexer.Token = undefined;
    var ops_top: usize = 0;
    var out_pos: usize = 0;

    while (true) {
        const tok = lex.next();
        if (tok.tag == .eof) break;

        switch (tok.tag) {
            .identifier, .number => {
                output[out_pos] = tok;
                out_pos += 1;
            },
            .op_add, .op_mul => {
                while (ops_top > 0 and ops_stack[ops_top-1].priority() >= tok.priority()) {
                    ops_top -= 1;
                    output[out_pos] = ops_stack[ops_top];
                    out_pos += 1;
                }
                ops_stack[ops_top] = tok;
                ops_top += 1;
            },
            else => {},
        }
    }
    while (ops_top > 0) {
        ops_top -= 1;
        output[out_pos] = ops_stack[ops_top];
        out_pos += 1;
    }
    return out_pos;
}
