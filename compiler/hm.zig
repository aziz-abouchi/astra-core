
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
        .App => |ax| occurs(tv, ax.f) or occurs(tv, ax.x),
        .Arrow => |ab| occurs(tv, ab.a) or occurs(tv, ab.b),
        .Forall => |fa| blk: {
            // si lié, ignorer
            for (fa.tvs) |b| if (b.id == tv.id) break :blk false;
            break :blk occurs(tv, fa.body);
        },
        .Con => false,
    };
}

pub fn unify(alloc: std.mem.Allocator, s: *Subst, a: *Type, b: *Type) !void {
    // apply subst (à écrire) puis unifier selon les formes
    // Var: bind si pas occurs
    // Arrow/App/Forall: structure
    // Con: égalité par nom
    // ... (impl détaillée à compléter)
    _ = alloc; _ = s; _ = a; _ = b;
}

test "unification simple (a -> a) ~ (Int -> Int)" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const A = gpa.allocator();

    var s = Subst.init(A);
    defer s.deinit();
    // Construis types et appelle unify(...)
    try std.testing.expect(true);
}

