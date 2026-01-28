pub const Type = union(enum) {
    Int: void,
    Bool: void,

    // fonction : from -> to
    Fn: struct { 
        from: *const Type, 
        to: *const Type 
    },

    // variable de type (Hindley-Milner)
    Var: u32,

    // type de session
    Session: *const Session,
    Void: void,
};

pub const Session = union(enum) {
    End: void,

    Send: struct { to: []const u8, msg: *const Type, next: *const Session },
    Recv: struct { from: []const u8, msg: *const Type, next: *const Session },

    Choose: struct { // ⊕
        cases: []const Case, // Case = { label, next }
    },

    Offer: struct { // &
        cases: []const Case,
    },
};

pub const Case = struct {
    label: []const u8,
    next: *const Session,
};

