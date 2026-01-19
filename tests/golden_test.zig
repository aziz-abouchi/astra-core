
const std = @import("std");
const vm = @import("vm_extended");

test "evalFactorialAST correctness" {
    const res = vm.evalFactorialAST(5);
    try std.testing.expect(res == 120);
}

test "QTT strictness double-use violation" {
    const ok = vm.enforceQTTDoubleUse();
    try std.testing.expect(!ok);
}
