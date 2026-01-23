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
    const body = lam.body orelse
        @panic("Lambda body is null");
    const body_ty = typeOf(body, env);

    const fn_ty = alloc.create(Type) catch unreachable;
    fn_ty.* = .{ .Fn = .{ .from = param_ty, .to = body_ty } };
    break :blk fn_ty;
},
.Apply => |app| blk: {
    const fn_ty = typeOf(app.fn_expr, env);
    const arg_ty = typeOf(app.arg_expr, env);

    // Vérifie QTT
    if (app.qtt) |q| {
        if (q == 0) @panic("Quantity exhausted for application");
    }

    switch (fn_ty.*) {
        .Fn => |f| {
            if (f.from != arg_ty)
                @panic("Function argument type mismatch");
            break :blk f.to;
        },
        else => @panic("Attempt to apply non-function"),
    }
},

.Send => |s| {
    const chan = env.get("chan") orelse @panic("No session");
    if (chan.* != .Session) @panic("Not a session");

    const sess = chan.Session;
    if (sess.* != .Send) @panic("Send not allowed");

    const msg_ty = typeOf(s.msg, env);
    if (msg_ty != sess.Send.msg)
        @panic("Message type mismatch");

    // CONSUME session
    chan.* = .{ .Session = sess.Send.next };
    return msg_ty;
},
.Recv => |r| {
    const chan = env.get("chan") orelse @panic("No session");
    if (chan.* != .Session) @panic("Not a session");

    const sess = chan.Session;
    if (sess.* != .Recv) @panic("Recv not allowed");

    env.put(r.var_name, sess.Recv.msg);

    chan.* = .{ .Session = sess.Recv.next };
    return sess.Recv.msg;
},
};
}
