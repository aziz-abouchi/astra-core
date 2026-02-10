
const std = @import("std");

pub fn main() !void {
    // IR JSON déterministe (utile pour les goldens)
    const out =
        "{\n" ++
        "  \"module\": \"heaven.ir\",\n" ++
        "  \"decls\": [],\n" ++
        "  \"meta\": { \"profile\": \"test\" }\n" ++
        "}\n";

    // Impression stdout compatible Zig 0.15.x
    std.debug.print("{s}", .{ out });
}

