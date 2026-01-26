const std = @import("std");
const Type = @import("astra_types.zig").Type;
const Session = @import("astra_types.zig").Session;
const Expr = @import("astra_ast.zig").Expr;
const TypeEnv = @import("astra_env.zig").TypeEnv;

pub fn typeEquals(a: *Type, b: *Type) bool {
    if (a == b) return true;
//    if (@intFromPtr(a) == @intFromPtr(b)) return true;

    return switch (a.*) {
        .Int => b.* == .Int,
        .Bool => b.* == .Bool,

        .Var => |va| switch (b.*) {
            .Var => |vb| va == vb,
            else => false,
        },

        .Fn => |fa| switch (b.*) {
            .Fn => |fb|
                typeEquals(fa.from, fb.from) and
                typeEquals(fa.to, fb.to),
            else => false,
        },

        .Session => |sa| switch (b.*) {
            .Session => |sb| sessionEquals(sa, sb),
            else => false,
        },
    };
}

fn typeAccepts(param: *Type, arg: *Type) bool {
    return switch (param.*) {
        .Var => true, // HM instantiation (simplifiée)
        else => typeEquals(param, arg),
    };
}

pub fn sessionEquals(sa: *Session, sb: *Session) bool {
    if (@intFromPtr(sa) == @intFromPtr(sb)) return true;

    return switch (sa.*) {
        .End => sb.* == .End,

        .Send => |s1| switch (sb.*) {
            .Send => |s2|
                typeEquals(s1.msg, s2.msg) and
                sessionEquals(s1.next, s2.next),
            else => false,
        },

        .Recv => |r1| switch (sb.*) {
            .Recv => |r2|
                typeEquals(r1.msg, r2.msg) and
                sessionEquals(r1.next, r2.next),
            else => false,
        },
    };
}

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
            if (!typeAccepts(f.from, arg_ty))
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

    if (s.msg == null) @panic("Send message is null");
    const msg_ty = typeOf(s.msg.?, env);
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
