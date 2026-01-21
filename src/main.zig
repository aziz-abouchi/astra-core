const std = @import("std");
pub fn main() !void { var gpa = std.heap.GeneralPurposeAllocator(.{}){}; defer _ = gpa.deinit(); const a = gpa.allocator(); _ = a; std.debug.print("Astra-Core (EQSAT) — Zig 0.15 build OK\n", .{}); }
