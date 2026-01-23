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
    const s_end = try alloc.create(astra_types.Session);
    s_end.* = .End;

    var bool_type: astra_types.Type = astra_types.Type.Bool;
    const s_recv = try alloc.create(astra_types.Session);
    s_recv.* = .{
        .Recv = .{
            .from = "Server",
            .msg = &bool_type,
            .next = s_end,
        },
    };

    var int_type: astra_types.Type = astra_types.Type.Int;
    const s_send = try alloc.create(astra_types.Session);
    s_send.* = .{
        .Send = .{
            .to = "Server",
            .msg = &int_type,
            .next = s_recv,
        },
    };

    var t: astra_types.Type = astra_types.Type{ .Session = s_send };
    env.put("chan", &t);

    // Send
    var send = astra_ast.Expr{
        .Send = .{ .to = "Server", .msg = &astra_ast.Expr{ .Var = "x" } },
    };
    env.put("x", &astra_types.Type.Int);

    _ = astra_typecheck.typeOf(&send, &env);

    // Recv
    var recv = astra_ast.Expr{
        .Recv = .{ .from = "Server", .var_name = "y" },
    };

    _ = astra_typecheck.typeOf(&recv, &env);
}

test "LOT 4.3 double send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    const s_end = try alloc.create(astra_types.Session);
    s_end.* = .End;

    var int_type: astra_types.Type = astra_types.Type.Int;
    const s_send = try alloc.create(astra_types.Session);
    s_send.* = .{
        .Send = .{
            .to = "Server",
            .msg = &int_type,
            .next = s_end,
        },
    };

    env.put("chan", &astra_types.Type{ .Session = s_send });

    var send_expr = astra_ast.Expr{
        .Send = .{ .to = "Server", .msg = &astra_ast.Expr{ .Var = "x" } },
    };
    env.put("x", &astra_types.Type.Int);

    // Premier envoi passe
    const passe1 = astra_typecheck.typeOf(&send_expr, &env);
    std.testing.expect(passe1 == null);

    // Second envoi → doit paniquer
    const passe2 = astra_typecheck.typeOf(&send_expr, &env);
    std.testing.expect(passe2 == null);
}

test "LOT 4.3 recv before send must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    const s_end = try alloc.create(astra_types.Session);
    s_end.* = .End;

    var int_type: astra_types.Type = astra_types.Type.Int;
    const s_send = try alloc.create(astra_types.Session);
    s_send.* = .{
        .Send = .{
            .to = "Server",
            .msg = &int_type,
            .next = s_end,
        },
    };

    env.put("chan", &astra_types.Type{ .Session = s_send });

    var recv = astra_ast.Expr{
        .Recv = .{ .from = "Server", .var_name = "x" },
    };

    const rcvBfSend = astra_typecheck.typeOf(&recv, &env);
    std.testing.expect(rcvBfSend == null);
}
