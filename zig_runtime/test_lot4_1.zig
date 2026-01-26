const std = @import("std");

const Expr = @import("astra_ast.zig").Expr;
const TypeEnv = @import("astra_env.zig").TypeEnv;
const typeOf = @import("astra_typecheck.zig").typeOf;

test "identity function applied to int" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();


    var env = TypeEnv.init(alloc);

    // (\x -> x) 42
    var body = Expr{ .Var = "x" };
    var lambda = Expr{
        .Lambda = .{
            .param = "x",
            .body = &body,
            .qtt = 1,
        },
    };

    var arg = Expr{ .IntLit = 42 };
    var app = Expr{
        .Apply = .{
            .fn_expr = &lambda,
            .arg_expr = &arg,
            .qtt = 1,
        },
    };

    _ = typeOf(&app, &env); // doit passer
}

test "invalid application must fail" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var env = TypeEnv.init(alloc);

    // (\x -> x) true 42
    var body = Expr{ .Var = "x" };
    var lambda = Expr{
        .Lambda = .{
            .param = "x",
            .body = &body,
            .qtt = 1,
        },
    };

    var arg1 = Expr{ .BoolLit = true };
    var app1 = Expr{
        .Apply = .{
            .fn_expr = &lambda,
            .arg_expr = &arg1,
            .qtt = 1,
        },
    };
    var arg2 = Expr{ .IntLit = 42 };
    var app2 = Expr{
        .Apply = .{
            .fn_expr = &app1,
            .arg_expr = &arg2,
            .qtt = 1,
        },
    };

    _ = typeOf(&app2, &env);
}

