const std = @import("std");

const astra_types = @import("astra_types.zig");
const Expr = @import("astra_ast.zig").Expr;
pub const TypeEnv = @import("astra_env.zig").TypeEnv;

const Type = astra_types.Type;
const Session = astra_types.Session;

pub const TypeError = error{
    ApplyNonFunction,
    NoSession,
    NotASession,
    InvalidSend,
    InvalidRecv,
    InvalidSelect,
    InvalidBranch,
    MessageTypeMismatch,
};

pub fn typeEquals(a: *const Type, b: *const Type) bool {
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

fn typeAccepts(param: *const Type, arg: *const Type) bool {
    return switch (param.*) {
        .Var => true, // HM instantiation (simplifiée)
        else => typeEquals(param, arg),
    };
}

pub fn sessionEquals(sa: *const Session, sb: *const Session) bool {
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

        .Choose => |ac| switch (sb.*) {
            .Choose => |bc| blk: {
                if (ac.cases.len != bc.cases.len) break :blk false;
                var i: usize = 0;
                while (i < ac.cases.len) : (i += 1) {
                    if (!std.mem.eql(u8, ac.cases[i].label, bc.cases[i].label))
                        break :blk false;
                    if (!sessionEquals(ac.cases[i].next, bc.cases[i].next))
                        break :blk false;
                }
                break :blk true;
            },
            else => false,
        },

        .Offer => |ac| switch (sb.*) {
            .Offer => |bc| blk: {
                if (ac.cases.len != bc.cases.len) break :blk false;
                var i: usize = 0;
                while (i < ac.cases.len) : (i += 1) {
                    if (!std.mem.eql(u8, ac.cases[i].label, bc.cases[i].label))
                        break :blk false;
                    if (!sessionEquals(ac.cases[i].next, bc.cases[i].next))
                        break :blk false;
                }
                break :blk true;
            },
            else => false,
        },

    };
}

pub fn typeOf(expr: *Expr, env: *TypeEnv) TypeError!*const Type {
    const alloc = env.alloc;

    return switch (expr.*) {
    .Int => blk: {
        const t = alloc.create(Type) catch unreachable;
        t.* = Type.Int;
        break :blk t;
    },

    .Bool => blk: {
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
    const body_ty = try typeOf(body, env);

    const fn_ty = alloc.create(Type) catch unreachable;
    fn_ty.* = .{ .Fn = .{ .from = param_ty, .to = body_ty } };
    break :blk fn_ty;
},
.Apply => |apply| blk: {
    const fn_ty = try typeOf(apply.fn_expr, env);
    const arg_ty = try typeOf(apply.arg_expr, env);

    // Vérifie QTT
    if (apply.qtt) |q| {
        if (q == 0) @panic("Quantity exhausted for application");
    }

    switch (fn_ty.*) {
        .Fn => |f| {
            if (!typeAccepts(f.from, arg_ty))
                return TypeError.MessageTypeMismatch;
            break :blk f.to;
        },
        else => return TypeError.ApplyNonFunction,
    }
},

.Send => |s| {
    const chan = env.get(s.to) orelse return TypeError.NoSession;
    if (chan.* != .Session) return TypeError.NotASession;
    const sess = chan.Session;
    if (sess.* != .Send) return TypeError.InvalidSend;


    if (s.msg == null) @panic("Send message is null");
    const msg_ty = try typeOf(s.msg.?, env);
    if (!typeEquals(msg_ty, sess.Send.msg))
        return TypeError.MessageTypeMismatch;

    var new_chan_ty = Type{
        .Session = sess.Send.next,
    };

    env.put(s.to, &new_chan_ty);

    return msg_ty;
},
.Recv => |r| {
    const chan = env.get(r.from) orelse return TypeError.NoSession; 
    if (chan.* != .Session) return TypeError.NotASession;

    const sess = chan.Session;
    if (sess.* != .Recv) return TypeError.InvalidRecv;

    env.put(r.msg, sess.Recv.msg);

    var new_chan_ty = Type{
        .Session = sess.Recv.next,
    };
    env.put(r.from, &new_chan_ty);

    return sess.Recv.msg;
},
.Select => |s| {
    const chan = env.get(s.chan) orelse return TypeError.NoSession;
    if (chan.* != .Session) return TypeError.NotASession;

    const sess = chan.Session;
    if (sess.* != .Choose) return TypeError.InvalidSelect;

    // chercher la branche
    for (sess.Choose.cases) |c| {
        if (std.mem.eql(u8, c.label, s.label)) {
            var new_ty = Type{ .Session = c.next };
            env.put(s.chan, &new_ty);

            const void_ty = Type{ .Void = {} };
            return &void_ty;
        }
    }

    return TypeError.InvalidSelect;
},
.Branch => |b| {
    const chan = env.get(b.chan) orelse return TypeError.NoSession;
    if (chan.* != .Session) return TypeError.NotASession;

    const sess = chan.Session;
    if (sess.* != .Offer) return TypeError.InvalidBranch;

    // vérifier que toutes les branches du protocole sont présentes
    for (sess.Offer.cases) |proto_case| {
        var found = false;
        for (b.cases) |ast_case| {
            if (std.mem.eql(u8, ast_case.label, proto_case.label)) {
                found = true;

                // typer le corps sous la session correspondante
                var new_ty = Type{ .Session = proto_case.next };
                env.put(b.chan, &new_ty);

                _ = try typeOf(ast_case.body, env);

                break;
            }
        }
        if (!found) return TypeError.InvalidBranch;
    }

    // après toutes les branches, la session doit être End
    var final_ty = Type{ .Session = sess.Offer.cases[0].next };
    env.put(b.chan, &final_ty);

    const void_ty = Type{ .Void = {} };
    return &void_ty;
},

};
}
