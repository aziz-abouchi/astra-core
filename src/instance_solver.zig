const std = @import("std");

pub const Constraint = struct { trait: []const u8, ty: []const u8 };

pub fn solve(constraints: []Constraint) bool { // MVP: supports Eq Nat only for (constraints) |c| { if (std.mem.eql(u8, c.trait, "Eq") and std.mem.eql(u8, c.ty, "Nat")) continue; return false; } return true; }
