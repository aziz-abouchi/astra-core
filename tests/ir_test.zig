
const std = @import("std");
const ir = @import("ir");

test "build and print factorial_tail IR" {
  const alloc = std.heap.page_allocator;
  const f = ir.build_factorial_tail_ir(alloc);

  var storage: [4096]u8 = undefined;
  var fbs = std.io.fixedBufferStream(&storage);
  const w = fbs.writer();
  try ir.printFunction(w, f);

  const s = fbs.getWritten();
  try std.testing.expect(std.mem.indexOf(u8, s, "function factorial_tail") != null);
  try std.testing.expect(std.mem.indexOf(u8, s, "%b0: ; entry") != null);
}
