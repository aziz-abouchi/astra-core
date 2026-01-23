const std = @import("std");
const Type = @import("astra_types.zig").Type;
const Expr = @import("astra_ast.zig").Expr;
const TypeEnv = @import("astra_env.zig").TypeEnv;

pub fn typeOf(expr: *Expr, env: *TypeEnv) *Type {
    const alloc = env.allocator;

    return switch (expr.*) {
    .IntLit => blk: {
        const t = alloc.create(Type) catch unreachable;
        t.* = Type.Int;
        break :blk t;
    },

    .BoolLit => blk: {
        const t = alloc.create(Type) catch unreachable;
        t.* = Type.Bool;
        break :blk t;
    },

    .Var => |name| env.get(name) orelse @panic("Unknown variable"),

.Lambda => |lam| blk: {
    const param_ty = alloc.create(Type) catch unreachable;
    param_ty.* = .{ .Var = 0 }; // <- syntaxe 0.15

    env.put(lam.param, param_ty);
    const body_ty = typeOf(lam.body, env);

    const fn_ty = alloc.create(Type) catch unreachable;
    fn_ty.* = .{ .Fn = .{ .from = param_ty, .to = body_ty } };
    break :blk fn_ty;
},

    .Apply => |app| blk: {
        const fn_ty = typeOf(app.fn_expr, env);
        const arg_ty = typeOf(app.arg_expr, env);

        switch (fn_ty.*) {
            .Fn => |f| {
                if (f.from != arg_ty)
                    @panic("Function argument type mismatch");
                break :blk f.to;
            },
            else => @panic("Attempt to apply non-function"),
        }
    },
};

}

