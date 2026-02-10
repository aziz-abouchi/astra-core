const std = @import("std");
const heaven_env = @import("heaven_env.zig");
const heaven_types = @import("heaven_types.zig");
const heaven_ast = @import("heaven_ast.zig");
const heaven_typecheck = @import("heaven_typecheck.zig");

test "LOT 4.4 select valid" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    // session : ⊕ { L1 : End, L2 : End }
    var s_end = heaven_types.Session{ .End = {} };

    var cases = [_]heaven_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var choose = heaven_types.Session{
        .Choose = .{ .cases = cases[0..] },
    };

    var chan_ty = heaven_types.Type{ .Session = &choose };
    env.put("chan", &chan_ty);

    var select_expr = heaven_ast.Expr{
        .Select = .{ .chan = "chan", .label = "L1" },
    };

    _ = try heaven_typecheck.typeOf(&select_expr, &env);
}

test "LOT 4.4 select invalid label" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = heaven_types.Session{ .End = {} };

    var cases = [_]heaven_types.Case{
        .{ .label = "L1", .next = &s_end },
    };

    var choose = heaven_types.Session{
        .Choose = .{ .cases = cases[0..] },
    };

    var chan_ty = heaven_types.Type{ .Session = &choose };
    env.put("chan", &chan_ty);

    var select_expr = heaven_ast.Expr{
        .Select = .{ .chan = "chan", .label = "L2" },
    };

    const res = heaven_typecheck.typeOf(&select_expr, &env);
    try std.testing.expectError(heaven_typecheck.TypeError.InvalidSelect, res);
}

test "LOT 4.4 branch valid" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = heaven_types.Session{ .End = {} };

    var cases = [_]heaven_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var offer = heaven_types.Session{
        .Offer = .{ .cases = cases[0..] },
    };

    var chan_ty = heaven_types.Type{ .Session = &offer };
    env.put("chan", &chan_ty);

    // AST branch
    var body1 = heaven_ast.Expr{ .Int = 42 };
    var body2 = heaven_ast.Expr{ .Bool = true };

    var branch_expr = heaven_ast.Expr{
        .Branch = .{
            .chan = "chan",
            .cases = &[_]heaven_ast.BranchCase{
                .{ .label = "L1", .body = &body1 },
                .{ .label = "L2", .body = &body2 },
            },
        },
    };

    _ = try heaven_typecheck.typeOf(&branch_expr, &env);
}

test "LOT 4.4 branch missing case" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(gpa.deinit() == .ok) catch unreachable;

    const alloc = gpa.allocator();
    var env = heaven_env.TypeEnv.init(alloc);
    defer env.deinit();

    var s_end = heaven_types.Session{ .End = {} };

    var cases = [_]heaven_types.Case{
        .{ .label = "L1", .next = &s_end },
        .{ .label = "L2", .next = &s_end },
    };

    var offer = heaven_types.Session{
        .Offer = .{ .cases = cases[0..] },
    };

    var chan_ty = heaven_types.Type{ .Session = &offer };
    env.put("chan", &chan_ty);

    // AST branch missing L2
    var body1 = heaven_ast.Expr{ .Int = 42 };

    var branch_expr = heaven_ast.Expr{
        .Branch = .{
            .chan = "chan",
            .cases = &[_]heaven_ast.BranchCase{
                .{ .label = "L1", .body = &body1 },
            },
        },
    };

    const res = heaven_typecheck.typeOf(&branch_expr, &env);
    try std.testing.expectError(heaven_typecheck.TypeError.InvalidBranch, res);
}

