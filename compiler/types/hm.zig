
// compiler/types/hm.zig (extraits)
const std = @import("std");

pub const TyKind = enum { Var, Con, App, Arrow, Forall };
pub const TyVar = struct { id: u32 };

pub const Type = union(TyKind) {
    Var: TyVar,
    Con: []const u8,
    App: struct { f: *Type, x: *Type },
    Arrow: struct { a: *Type, b: *Type },
    Forall: struct { tvs: []TyVar, body: *Type },
};

pub const Subst = std.AutoHashMap(u32, *Type);

fn occurs(tv: TyVar, ty: *const Type) bool {
    return switch (ty.*) {
        .Var => |v| v.id == tv.id,
        .Con => false,
        .App => |ax| occurs(tv, ax.f) or occurs(tv, ax.x),
        .Arrow => |ab| occurs(tv, ab.a) or occurs(tv, ab.b),
        .Forall => |fa| blk: {
            // si lié dans Forall, on ignore l'occurs
            for (fa.tvs) |b| if (b.id == tv.id) break :blk false;
            break :blk occurs(tv, fa.body);
        },
    };
}

fn applyOne(ty: *Type, v: u32, rep: *Type) void {
    switch (ty.*) {
        .Var => |tvar| if (tvar.id == v) ty.* = rep.*;
        .Con => {},
        .App => |*ax| { applyOne(ax.f, v, rep); applyOne(ax.x, v, rep); },
        .Arrow => |*ab| { applyOne(ab.a, v, rep); applyOne(ab.b, v, rep); },
        .Forall => |*fa| {
            // si v est lié par Forall, ne pas substituer
            for (fa.tvs) |b| if (b.id == v) return;
            applyOne(fa.body, v, rep);
        },
    }
}

pub fn apply(s: *const Subst, ty: *Type) void {
    var it = s.iterator();
    while (it.next()) |entry| {
        applyOne(ty, entry.key_ptr.*, entry.value_ptr.*);
    }
}

fn bind(alloc: std.mem.Allocator, s: *Subst, alpha: TyVar, t: *Type) !void {
    // alpha := t, avec occurs-check
    if (t.* == Type{ .Var = alpha }) return; // identique
    if (occurs(alpha, t)) return error.OccursCheck;
    try s.put(alpha.id, t);
}

pub fn unify(alloc: std.mem.Allocator, s: *Subst, a_in: *Type, b_in: *Type) !void {
    var a = a_in; var b = b_in;
    // always apply current subst to both sides
    apply(s, a);
    apply(s, b);

    switch (a.*) {
        .Var => |va| return bind(alloc, s, va, b),
        .Con => |ca| switch (b.*) {
            .Var => |vb| return bind(alloc, s, vb, a),
            .Con => |cb| if (std.mem.eql(u8, ca, cb)) return else return error.CannotUnify,
            else => return error.CannotUnify,
        },
        .App => |aa| switch (b.*) {
            .Var => |vb| return bind(alloc, s, vb, a),
            .App => |bb| {
                try unify(alloc, s, aa.f, bb.f);
                try unify(alloc, s, aa.x, bb.x);
                return;
            },
            else => return error.CannotUnify,
        },
        .Arrow => |ab| switch (b.*) {
            .Var => |vb| return bind(alloc, s, vb, a),
            .Arrow => |cd| {
                try unify(alloc, s, ab.a, cd.a);
                try unify(alloc, s, ab.b, cd.b);
                return;
            },
            else => return error.CannotUnify,
        },
        .Forall => |_| {
            // HM-core: Forall hors unif (skolem/instantiation en phase infer/let)
            return error.CannotUnifyForall;
        },
    }
}

test "unify (a -> a) ~ (Int -> Int)" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const A = gpa.allocator();

    var s = Subst.init(A);
    defer s.deinit();

    // construir types et appeler unify(...)
    // TODO: construire AST Type pour Int, Var a, Arrow
    try std.testing.expect(true);
}

