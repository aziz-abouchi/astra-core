const std = @import("std");

const Expr = @import("astra_ast.zig").Expr;
const TypeEnv = @import("astra_env.zig").TypeEnv;
const typeOf = @import("astra_typecheck.zig").typeOf;

test "invalid application must fail" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var env = TypeEnv.init(alloc);

    // (\x -> x) true 42
    var body = Expr{ .Var = "x" };
    var lambda = Expr{
        .Lambda = .{
            .param = "x",
            .body = &body,
        },
    };

    var arg1 = Expr{ .BoolLit = true };
    var app1 = Expr{
        .Apply = .{
            .fn_expr = &lambda,
            .arg_expr = &arg1,
        },
    };

    var arg2 = Expr{ .IntLit = 42 };
    var app2 = Expr{
        .Apply = .{
            .fn_expr = &app1,
            .arg_expr = &arg2,
        },
    };

    // doit PANIC
    _ = typeOf(&app2, &env);
}

