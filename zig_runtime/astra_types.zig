pub const Type = union(enum) {
    Int,
    Bool,
    Fn: struct { from: *Type, to: *Type },
    Var: u32,					// type variable (HM)
    Session: *Session,
};

pub const Session = union(enum) {
    Send: struct {
        to: []const u8,
        msg: *Type,
        next: *Session,
    },
    Recv: struct {
        from: []const u8,
        msg: *Type,
        next: *Session,
    },
    End,
};

