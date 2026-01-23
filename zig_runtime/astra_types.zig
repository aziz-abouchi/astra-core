pub const Type = union(enum) {
    Int,
    Bool,
    Unit,

    Fn: struct {
        from: *Type,
        to: *Type,
    },

    Var: u32, // type variable (HM)
};

