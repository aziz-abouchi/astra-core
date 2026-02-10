
const std = @import("std");

pub fn generateLLVMIRFactorialTail(w: anytype) !void {
try w.writeAll("; ModuleID = 'heaven'\n");
try w.writeAll("define i64 @factorial_tail(i64 %n) {\n");
try w.writeAll("entry:\n  %acc = alloca i64\n  store i64 1, i64* %acc\n  br label %loop\n\n");
try w.writeAll("loop:\n  %n_phi = phi i64 [ %n, %entry ], [ %n_next, %loop ]\n  %acc_val = load i64, i64* %acc\n  %cond = icmp eq i64 %n_phi, 0\n  br i1 %cond, label %exit, label %body\n\n");
try w.writeAll("body:\n  %acc2 = mul i64 %acc_val, %n_phi\n  store i64 %acc2, i64* %acc\n  %n_next = sub i64 %n_phi, 1\n  br label %loop\n\n");
try w.writeAll("exit:\n  %ret = load i64, i64* %acc\n  ret i64 %ret\n}\n");
}


pub fn main() !void {
    // Émission via stderr (portable)
    // Appelle directement generateLLVMIRFactorialTail avec un writer "in-memory",
    // puis flush via std.debug.print pour éviter tout mismatch d’API I/O.
    var storage: [1 << 15]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&storage);
    const w = fbs.writer();

    try generateLLVMIRFactorialTail(w);

    const out = fbs.getWritten();
    std.debug.print("{s}", .{out});
}
