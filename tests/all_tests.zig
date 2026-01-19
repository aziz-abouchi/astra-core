
comptime {
    _ = @import("golden_test.zig");
    _ = @import("ir_test.zig");
    _ = @import("smoke_test.zig");
    _ = @import("llvm_test.zig"); // remove if file absent
}
