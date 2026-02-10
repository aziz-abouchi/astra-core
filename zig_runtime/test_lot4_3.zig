const std = @import("std");
const heaven_env = @import("heaven_env.zig");
const heaven_types = @import("heaven_types.zig");
const heaven_ast = @import("heaven_ast.zig");
const heaven_typecheck  = @import("heaven_typecheck.zig");

test "LOT 4.3 valid linear session" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    // Session: send Int → recv Bool → End
    var bool_type: heaven_types.Type = heaven_types.Type.Bool;
    var int_type: heaven_types.Type = heaven_types.Type.Int;

    const s_end = heaven_types.Session{ .End = {} };

    const s_recv = heaven_types.Session{
        .Recv = .{
            .from = "chan",
            .msg = &bool_type,
            .next = &s_end,
        },
    };

    const s_send = heaven_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_recv,
        },
    };

    var t: heaven_types.Type = heaven_types.Type{ .Session = &s_send };
    env.put("chan", &t);

    var msg = heaven_ast.Expr{ .Var = "x" };
    // Send
    var send = heaven_ast.Expr{
        .Send = .{ .to = "chan", .msg = &msg },
    };
    var int_ty = heaven_types.Type{ .Int = {} };
    env.put("x", &int_ty);

    _ = try heaven_typecheck.typeOf(&send, &env);

    // Recv
    var recv = heaven_ast.Expr{
        .Recv = .{ .from = "chan", .msg = "y" },
    };

    _ = try heaven_typecheck.typeOf(&recv, &env);
}

test "LOT 4.3 double send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = heaven_types.Session{ .End = {} };
    var int_type = heaven_types.Type{ .Int = {} };
    var s_send = heaven_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_end,
        },
    };

    var chan_ty = heaven_types.Type{ .Session = &s_send };
    env.put("chan", &chan_ty);

    var msg = heaven_ast.Expr{ .Var = "x" };
    var send_expr = heaven_ast.Expr{
        .Send = .{ .to = "chan", .msg = &msg },
    };
    env.put("x", &int_type);

    // Premier envoi : OK
    _ = try heaven_typecheck.typeOf(&send_expr, &env);

    const passe2 = heaven_typecheck.typeOf(&send_expr, &env);
    try std.testing.expectError(heaven_typecheck.TypeError.InvalidSend, passe2);
}

test "LOT 4.3 recv before send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = heaven_types.Session{ .End = {} };

    var int_type = heaven_types.Type{ .Int = {} };
    var s_send = heaven_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_end,
        },
    };

    var chan_ty = heaven_types.Type{ .Session = &s_send };
    env.put("chan", &chan_ty);

    var recv = heaven_ast.Expr{
        .Recv = .{ .from = "chan", .msg = "x" },
    };

    const rcvBfSend = heaven_typecheck.typeOf(&recv, &env);
    try std.testing.expectError(heaven_typecheck.TypeError.InvalidRecv, rcvBfSend);
}
