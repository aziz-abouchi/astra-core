pub const Expr = union(enum) {
    IntLit: i64,
    BoolLit: bool,
    Var: []const u8,
    Lambda: struct { param: []const u8, body: ?*Expr, qtt: u32 },
    Apply: struct { fn_expr: *Expr, arg_expr: *Expr, qtt: ?u32 },
    Send: struct { to: []const u8, msg: ?*Expr },
    Recv: struct { from: []const u8, var_name: []const u8 },
};

