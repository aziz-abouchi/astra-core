
const std = @import("std");
const ir = @import("ir");

test "smoke: IR printer returns non-empty buffer" {
  const alloc = std.heap.page_allocator;
  const f = ir.build_factorial_tail_ir(alloc);

  var storage: [2048]u8 = undefined;
  var fbs = std.io.fixedBufferStream(&storage);
  const w = fbs.writer();
  try ir.printFunction(w, f);

  const s = fbs.getWritten();
  try std.testing.expect(s.len > 0);
}
