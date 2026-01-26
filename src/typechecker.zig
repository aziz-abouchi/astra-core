const std = @import("std");
const ast = @import("ast.zig");
const types = @import("types.zig");

const Allocator = std.mem.Allocator;
const Expr = ast.Expr;
const Type = types.Type;

pub const TypeEnv = struct {
    allocator: Allocator,
    entries: std.StringHashMap(*Type),

    pub fn init(allocator: Allocator) TypeEnv {
        return .{
            .allocator = allocator,
            .entries = std.StringHashMap(*Type).init(allocator),
        };
    }

    pub fn put(self: *TypeEnv, name: []const u8, ty: *Type) !void {
        try self.entries.put(name, ty);
    }

    pub fn get(self: *TypeEnv, name: []const u8) ?*Type {
        return self.entries.get(name);
    }
};

pub fn infer(env: *TypeEnv, allocator: Allocator, expr: *Expr) !*Type {
    switch (expr.*) {
        .Var => |name| {
            const t = env.get(name) orelse return error.UnboundVariable;
            return t;
        },
        .Fun => |f| {
            const param_ty = try allocator.create(Type);
            param_ty.* = Type{ .Var = f.param }; // placeholder
            try env.put(f.param, param_ty);
            const body_ty = try infer(env, allocator, f.body);
            const fun_ty = try allocator.create(Type);
            fun_ty.* = Type{ .Arrow = .{ .from = param_ty, .to = body_ty } };
            return fun_ty;
        },
        .App => |a| {
            const f_ty = try infer(env, allocator, a.func);
            const arg_ty = try infer(env, allocator, a.arg);
            _ = arg_ty; // pour l’instant on ne vérifie pas la compatibilité
            return f_ty;
        },
        .Let => |l| {
            const v_ty = try infer(env, allocator, l.value);
            try env.put(l.name, v_ty);
            return infer(env, allocator, l.body);
        },
    }
}

