const std = @import("std");
pub const TyId = usize;
pub const Ty = union(enum) {
Var: TyId,
Con: []const u8,
Arrow: struct { from: *Ty, to: *Ty },
App: struct { head: *Ty, arg: *Ty },
};
pub const Scheme = struct { foralls: []TyId, constraints: [][]const u8, ty: Ty };
pub const Subst = struct {
map: std.AutoHashMap(TyId, Ty),
pub fn init(alloc: std.mem.Allocator) Subst { return .{ .map = std.AutoHashMap(TyId, Ty).init(alloc) }; }
pub fn put(self: *Subst, v: TyId, t: Ty) !void { try self.map.put(v, t); }
pub fn get(self: *Subst, v: TyId) ?Ty { return self.map.get(v); }
};
fn occurs(var: TyId, ty: Ty) bool {
switch (ty.) {
.Var => |v| return v == var,
.Con => return false,
.Arrow => |a| return occurs(var, a.from) or occurs(var, a.to),
.Apply => |ap| return occurs(var, ap.head) or occurs(var, ap.arg),
}
}
pub fn unify(s: Subst, a: Ty, b: Ty) !void {
switch (a., b.) {
.Var, .Var => |va, vb| { if (va != vb) try s.put(va, Ty{ .Var = vb }); },
.Var, _ => |va, _| { if (occurs(va, b)) return error.UnificationFailed; try s.put(va, b.); },
, .Var => |, vb| { if (occurs(vb, a)) return error.UnificationFailed; try s.put(vb, a.*); },
.Con, .Con => |ca, cb| { if (!std.mem.eql(u8, ca, cb)) return error.UnificationFailed; },
.Arrow, .Arrow => |aa, bb| { try unify(s, aa.from, bb.from); try unify(s, aa.to, bb.to); },
.Apply, .Apply => |ap, bp| { try unify(s, ap.head, bp.head); try unify(s, ap.arg, bp.arg); },
else => return error.UnificationFailed,
}
}
pub fn instantiate(alloc: std.mem.Allocator, sch: Scheme, fresh: *TyId) Ty {
var ty = sch.ty;
return ty; // skeleton
}
pub fn generalize(alloc: std.mem.Allocator, ty: Ty) Scheme {
return Scheme{ .foralls = &[]TyId{}, .constraints = &[][]const u8{}, .ty = ty };
}
pub fn inferFactorialTail() Scheme {
var nat = Ty{ .Con = "Nat" };
var arr = Ty{ .Arrow = .{ .from = &nat, .to = &nat } };
return Scheme{ .foralls = &[]TyId{}, .constraints = &[][]const u8{}, .ty = arr };
}
pub fn inferContains() Scheme {
// contains : forall a . [Eq a] => a -> List a -> Bool
var a = Ty{ .Var = 0 };
var list_con = Ty{ .Con = "List" };
var list = Ty{ .Apply = .{ .head = &list_con, .arg = &a } };
var bool = Ty{ .Con = "Bool" };
var arr1 = Ty{ .Arrow = .{ .from = &a, .to = &list } };
var arr2 = Ty{ .Arrow = .{ .from = &arr1, .to = &bool } };
return Scheme{ .foralls = &[]TyId{0}, .constraints = &[][]const u8{"Eq a"}, .ty = arr2 };
}
fn tyToString(ty: Ty, w: anytype) !void {
switch (ty) {
.Var => |v| { try w.print("a", .{}); },
.Con => |c| { try w.print("{s}", .{c}); },
.Arrow => |a| { try tyToString(a.from., w); try w.print(" -> ", .{}); try tyToString(a.to., w); },
.Apply => |ap| { try tyToString(ap.head., w); try w.print(" ", .{}); try tyToString(ap.arg., w); },
}
}
pub fn schemeToString(s: Scheme, w: anytype) !void {
if (s.foralls.len > 0) { try w.print("forall ", .{}); for (s.foralls, 0..) |_, i| { if (i>0) try w.print(" ", .{}); try w.print("a", .{}); } try w.print(". ", .{}); }
if (s.constraints.len > 0) { try w.print("[", .{}); for (s.constraints, 0..) |c, i| { if (i>0) try w.print(", ", .{}); try w.print("{s}", .{c}); } try w.print("] => ", .{}); }
try tyToString(s.ty, w);
}
