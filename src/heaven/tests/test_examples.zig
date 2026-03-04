const std = @import("std");
const Heaven = @import("../ast.zig");

test "Execute Fact example" {
    const code = std.fs.readFileToEndAlloc(std.heap.page_allocator, "src/heaven/examples/fact.heaven") catch unreachable;
    defer std.heap.page_allocator.free(code);
    var ast = Heaven.parse(code) catch unreachable;
    Heaven.typecheck(ast) catch unreachable;
    Heaven.runtime.execute(ast);
    try std.testing.expect(true); // placeholder
}
