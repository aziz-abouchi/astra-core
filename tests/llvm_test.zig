
const std = @import("std");
const gen = @import("llvm_codegen");

test "LLVM generator emits factorial_tail signature" {
    var storage: [4096]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&storage);
    const w = fbs.writer();

    try gen.generateLLVMIRFactorialTail(w);

    const out = fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, out, "define i64 @factorial_tail(i64 %n)") != null);
}
