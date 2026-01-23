pub const Expr = union(enum) {
    IntLit: i64,
    BoolLit: bool,

    Var: []const u8,

    Lambda: struct {
        param: []const u8,
        body: *Expr,
    },

    Apply: struct {
        fn_expr: *Expr,
        arg_expr: *Expr,
    },
};

