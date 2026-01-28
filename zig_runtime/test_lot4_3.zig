const std = @import("std");
const astra_env = @import("astra_env.zig");
const astra_types = @import("astra_types.zig");
const astra_ast = @import("astra_ast.zig");
const astra_typecheck  = @import("astra_typecheck.zig");

test "LOT 4.3 valid linear session" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    // Session: send Int → recv Bool → End
    var bool_type: astra_types.Type = astra_types.Type.Bool;
    var int_type: astra_types.Type = astra_types.Type.Int;

    const s_end = astra_types.Session{ .End = {} };

    const s_recv = astra_types.Session{
        .Recv = .{
            .from = "chan",
            .msg = &bool_type,
            .next = &s_end,
        },
    };

    const s_send = astra_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_recv,
        },
    };

    var t: astra_types.Type = astra_types.Type{ .Session = &s_send };
    env.put("chan", &t);

    var msg = astra_ast.Expr{ .Var = "x" };
    // Send
    var send = astra_ast.Expr{
        .Send = .{ .to = "chan", .msg = &msg },
    };
    var int_ty = astra_types.Type{ .Int = {} };
    env.put("x", &int_ty);

    _ = try astra_typecheck.typeOf(&send, &env);

    // Recv
    var recv = astra_ast.Expr{
        .Recv = .{ .from = "chan", .msg = "y" },
    };

    _ = try astra_typecheck.typeOf(&recv, &env);
}

test "LOT 4.3 double send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = astra_types.Session{ .End = {} };
    var int_type = astra_types.Type{ .Int = {} };
    var s_send = astra_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_end,
        },
    };

    var chan_ty = astra_types.Type{ .Session = &s_send };
    env.put("chan", &chan_ty);

    var msg = astra_ast.Expr{ .Var = "x" };
    var send_expr = astra_ast.Expr{
        .Send = .{ .to = "chan", .msg = &msg },
    };
    env.put("x", &int_type);

    // Premier envoi : OK
    _ = try astra_typecheck.typeOf(&send_expr, &env);

    const passe2 = astra_typecheck.typeOf(&send_expr, &env);
    try std.testing.expectError(astra_typecheck.TypeError.InvalidSend, passe2);
}

test "LOT 4.3 recv before send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = astra_types.Session{ .End = {} };

    var int_type = astra_types.Type{ .Int = {} };
    var s_send = astra_types.Session{
        .Send = .{
            .to = "chan",
            .msg = &int_type,
            .next = &s_end,
        },
    };

    var chan_ty = astra_types.Type{ .Session = &s_send };
    env.put("chan", &chan_ty);

    var recv = astra_ast.Expr{
        .Recv = .{ .from = "chan", .msg = "x" },
    };

    const rcvBfSend = astra_typecheck.typeOf(&recv, &env);
    try std.testing.expectError(astra_typecheck.TypeError.InvalidRecv, rcvBfSend);
}
