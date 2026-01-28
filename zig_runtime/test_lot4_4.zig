const std = @import("std");
const astra_env = @import("astra_env.zig");
const astra_types = @import("astra_types.zig");
const astra_ast = @import("astra_ast.zig");
const astra_typecheck = @import("astra_typecheck.zig");

test "LOT 4.4 select valid" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    // session : ⊕ { L1 : End, L2 : End }
    var s_end = astra_types.Session{ .End = {} };

    var cases = [_]astra_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var choose = astra_types.Session{
        .Choose = .{ .cases = cases[0..] },
    };

    var chan_ty = astra_types.Type{ .Session = &choose };
    env.put("chan", &chan_ty);

    var select_expr = astra_ast.Expr{
        .Select = .{ .chan = "chan", .label = "L1" },
    };

    _ = try astra_typecheck.typeOf(&select_expr, &env);
}

test "LOT 4.4 select invalid label" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = astra_types.Session{ .End = {} };

    var cases = [_]astra_types.Case{
        .{ .label = "L1", .next = &s_end },
    };

    var choose = astra_types.Session{
        .Choose = .{ .cases = cases[0..] },
    };

    var chan_ty = astra_types.Type{ .Session = &choose };
    env.put("chan", &chan_ty);

    var select_expr = astra_ast.Expr{
        .Select = .{ .chan = "chan", .label = "L2" },
    };

    const res = astra_typecheck.typeOf(&select_expr, &env);
    try std.testing.expectError(astra_typecheck.TypeError.InvalidSelect, res);
}

test "LOT 4.4 branch valid" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = astra_types.Session{ .End = {} };

    var cases = [_]astra_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var offer = astra_types.Session{
        .Offer = .{ .cases = cases[0..] },
    };

    var chan_ty = astra_types.Type{ .Session = &offer };
    env.put("chan", &chan_ty);

    // AST branch
    var body1 = astra_ast.Expr{ .Int = 42 };
    var body2 = astra_ast.Expr{ .Bool = true };

    var branch_expr = astra_ast.Expr{
        .Branch = .{
            .chan = "chan",
            .cases = &[_]astra_ast.BranchCase{
                .{ .label = "L1", .body = &body1 },
                .{ .label = "L2", .body = &body2 },
            },
        },
    };

    _ = try astra_typecheck.typeOf(&branch_expr, &env);
}

test "LOT 4.4 branch missing case" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = astra_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = astra_types.Session{ .End = {} };

    var cases = [_]astra_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var offer = astra_types.Session{
        .Offer = .{ .cases = cases[0..] },
    };

    var chan_ty = astra_types.Type{ .Session = &offer };
    env.put("chan", &chan_ty);

    // AST branch missing L2
    var body1 = astra_ast.Expr{ .Int = 42 };

    var branch_expr = astra_ast.Expr{
        .Branch = .{
            .chan = "chan",
            .cases = &[_]astra_ast.BranchCase{
                .{ .label = "L1", .body = &body1 },
            },
        },
    };

    const res = astra_typecheck.typeOf(&branch_expr, &env);
    try std.testing.expectError(astra_typecheck.TypeError.InvalidBranch, res);
}

