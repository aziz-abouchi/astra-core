const std = @import("std"); const aw = @import("../src/algorithm_w.zig"); const inst = @import("../src/instance_solver.zig");

test "Algorithm W infers factorial_tail : Nat -> Nat" { const sch = aw.inferFactorialTail(); var buf = std.ArrayList(u8).init(std.heap.page_allocator); defer buf.deinit(); var w = buf.writer(); try aw.schemeToString(sch, w); const s = buf.items; try std.testing.expect(std.mem.indexOf(u8, s, "Nat -> Nat") != null); }

test "Algorithm W infers contains with [Eq a]" { const sch = aw.inferContains(); var buf = std.ArrayList(u8).init(std.heap.page_allocator); defer buf.deinit(); var w = buf.writer(); try aw.schemeToString(sch, w); const s = buf.items; try std.testing.expect(std.mem.indexOf(u8, s, "forall a") != null); try std.testing.expect(std.mem.indexOf(u8, s, "Eq a") != null); }

test "Instance solver resolves Eq Nat" { const ok = inst.solve(&[_]inst.Constraint{ .{ .trait = "Eq", .ty = "Nat" } }); try std.testing.expect(ok); }
