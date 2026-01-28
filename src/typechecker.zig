const std = @import("std");
const Allocator = std.mem.Allocator;
const ast = @import("ast.zig");
const types = @import("types.zig");

const Type = types.Type;
const Scheme = types.Scheme;
const TypeVarId = types.TypeVarId;

// Environnement de types
pub const TypeEnv = struct {
    map: std.StringHashMap(Scheme),
    alloc: Allocator,

    pub fn init(alloc: Allocator) TypeEnv {
        return .{
            .map = std.StringHashMap(Scheme).init(alloc),
            .alloc = alloc,
        };
    }

    pub fn put(self: *TypeEnv, name: []const u8, scheme: Scheme) !void {
        try self.map.put(name, scheme);
    }

    pub fn get(self: *TypeEnv, name: []const u8) ?Scheme {
        return self.map.get(name);
    }
};

// Génération de variables fraîches
var next_typevar: TypeVarId = 0;

fn freshTypeVar(alloc: Allocator) *Type {
    const t = alloc.create(Type) catch unreachable;
    t.* = .{ .Var = .{ .id = next_typevar } };
    next_typevar += 1;
    return t;
}

// Free Type Variables (FTV)
const VarSet = std.AutoHashMap(TypeVarId, void);

fn ftvType(t: *Type, set: *VarSet) void {
    switch (t.*) {
        .Var => |v| {
            set.put(v.id, {}) catch unreachable;
        },
        .Arrow => |a| {
            ftvType(a.from, set);
            ftvType(a.to, set);
        },
        else => {},
    }
}

fn ftvScheme(s: Scheme, set: *VarSet) void {
    ftvType(s.ty, set);
    for (s.vars) |v| {
        _ = set.remove(v);
    }
}

fn ftvEnv(env: *TypeEnv, set: *VarSet) void {
    var it = env.map.valueIterator();
    while (it.next()) |scheme| {
        ftvScheme(scheme.*, set);
    }
}

// Généralisation (LET)
fn generalize(env: *TypeEnv, ty: *Type, alloc: Allocator) Scheme {
    var ftv_t = VarSet.init(alloc);
    var ftv_e = VarSet.init(alloc);

    ftvType(ty, &ftv_t);
    ftvEnv(env, &ftv_e);

    var it = ftv_e.keyIterator();
    while (it.next()) |k| {
        _ = ftv_t.remove(k.*);
    }

    const vars = alloc.alloc(TypeVarId, ftv_t.count()) catch unreachable;
    var i: usize = 0;
    var it2 = ftv_t.keyIterator();
    while (it2.next()) |k| {
        vars[i] = k.*;
        i += 1;
    }

    return .{ .vars = vars, .ty = ty };
}

// Instanciation (VAR)
fn instantiate(s: Scheme, alloc: Allocator) *Type {
    var subst = std.AutoHashMap(TypeVarId, *Type).init(alloc);

    for (s.vars) |v| {
        subst.put(v, freshTypeVar(alloc)) catch unreachable;
    }

    return applySubst(s.ty, &subst, alloc);
}

// Substitution
fn applySubst(t: *Type, subst: *std.AutoHashMap(TypeVarId, *Type), alloc: Allocator) *Type {
    return switch (t.*) {
        .Var => |v| subst.get(v.id) orelse t,
        .Arrow => |a| blk: {
            const n = alloc.create(Type) catch unreachable;
            n.* = .{
                .Arrow = .{
                    .from = applySubst(a.from, subst, alloc),
                    .to = applySubst(a.to, subst, alloc),
                },
            };
            break :blk n;
        },
        else => t,
    };
}
// Substitution
fn substitute(t: *Type, var_id: TypeVarId, with: *Type) void {
    switch (t.*) {
        .Var => |id| {
            if (id == var_id) {
                t.* = with.*;
            }
        },
        .Arrow => |*a| {
            substitute(a.from, var_id, with);
            substitute(a.to, var_id, with);
        },
        else => {},
    }
}

// Occurs check (évite les types infinis)
fn occurs(var_id: TypeVarId, t: *Type) bool {
    return switch (t.*) {
        .Var => |id| id == var_id,
        .Arrow => |a| occurs(var_id, a.from) or occurs(var_id, a.to),
        else => false,
    };
}

// Unification (LE cœur)
fn unify(a: *Type, b: *Type) !void {
    if (a == b) return;

    switch (a.*) {
        .Var => |id| {
            if (occurs(id, b)) return error.InfiniteType;
            substitute(b, id, a);
            return;
        },

        .Arrow => |fa| switch (b.*) {
            .Arrow => |fb| {
                try unify(fa.from, fb.from);
                try unify(fa.to, fb.to);
                return;
            },
            else => return error.TypeMismatch,
        },

        .Int => switch (b.*) {
            .Int => return,
            else => return error.TypeMismatch,
        },

        .Bool => switch (b.*) {
            .Bool => return,
            else => return error.TypeMismatch,
        },
    }

    // Symétrie
    if (b.* == .Var) {
        try unify(b, a);
        return;
    }

    return error.TypeMismatch;
}

// Inference
pub fn infer(env: *TypeEnv, alloc: Allocator, expr: *ast.Expr) !*Type {
    return switch (expr.*) {

        .Int => blk: {
            const t = alloc.create(Type) catch unreachable;
            t.* = .Int;
            break :blk t;
        },

        .Bool => blk: {
            const t = alloc.create(Type) catch unreachable;
            t.* = .Bool;
            break :blk t;
        },

        .Var => |name| blk: {
            const scheme = env.get(name) orelse
                return error.UnknownVariable;
            break :blk instantiate(scheme, alloc);
        },

        .Lambda => |l| blk: {
            const tv = freshTypeVar(alloc);

            try env.put(
                l.param,
                .{ .vars = &[_]TypeVarId{}, .ty = tv },
            );

            const body_ty = try infer(env, alloc, l.body);

            const t = alloc.create(Type) catch unreachable;
            t.* = .{
                .Arrow = .{
                    .from = tv,
                    .to = body_ty,
                },
            };

            break :blk t;
        },

        .Apply => |a| blk: {
            const fn_ty = try infer(env, alloc, a.fn);
            const arg_ty = try infer(env, alloc, a.arg);
            const res_ty = freshTypeVar(alloc);

            // fn_ty must be arg_ty -> res_ty
            try unify(
                fn_ty,
                &Type{
                    .Arrow = .{
                        .from = arg_ty,
                        .to = res_ty,
                    },
                },
            );

            break :blk res_ty;
        },

        .Let => |l| blk: {
            const val_ty = try infer(env, alloc, l.value);
            const scheme = generalize(env, val_ty, alloc);
            try env.put(l.name, scheme);
            break :blk try infer(env, alloc, l.body);
        },
    };
}

