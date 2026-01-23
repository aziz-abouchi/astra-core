const std = @import("std");

const Expr = @import("astra_ast.zig").Expr;
const TypeEnv = @import("astra_env.zig").TypeEnv;
const typeOf = @import("astra_typecheck.zig").typeOf;

test "identity function applied to int" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var env = TypeEnv.init(alloc);

    // (\x -> x) 42
    var body = Expr{ .Var = "x" };
    var lambda = Expr{
        .Lambda = .{
            .param = "x",
            .body = &body,
        },
    };

    var arg = Expr{ .IntLit = 42 };
    var app = Expr{
        .Apply = .{
            .fn_expr = &lambda,
            .arg_expr = &arg,
        },
    };

    _ = typeOf(&app, &env); // doit passer
}
