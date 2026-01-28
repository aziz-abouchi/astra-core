pub const Expr = union(enum) {
    Int: i64,
    Bool: bool,
    Var: []const u8,

    // λx.qtt. body
    Lambda: struct { 
        param: []const u8, 
        body: ?*Expr, 
        qtt: u32 
    },

    // f x
    Apply: struct { 
        fn_expr: *Expr, 
        arg_expr: *Expr, 
        qtt: ?u32 
    },

    // send chan msg
    Send: struct { 
        to: []const u8, 
        msg: ?*Expr 
    },

    // recv chan x
    Recv: struct { 
        from: []const u8, 
        msg: []const u8 
    },

    Select: struct {
        chan: []const u8,
        label: []const u8,
    },

    Branch: struct {
        chan: []const u8,
        cases: []const struct {
            label: []const u8,
            body: *Expr,
        },
    },

};

pub const BranchCase = struct {
    label: []const u8,
    body: *Expr,
};
