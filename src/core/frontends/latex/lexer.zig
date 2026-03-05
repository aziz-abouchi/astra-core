// src/core/frontends/latex/lexer.zig
const TokenKind = enum {
    lbrace, // {
    rbrace, // }
    backslash_cmd, // \forall, \sum, etc.
    caret,  // ^
    underscore, // _
    // ...
};
