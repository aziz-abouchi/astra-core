const std = @import("std");

pub const Multiplicity = enum {
    zero,   // erased
    one,    // linear
    omega,  // unrestricted
};

pub const Type = union(enum) {
    Int,
    Float,
    Bool,
    Unit,

    Var: u32,

    Func: struct {
        arg: *Type,
        ret: *Type,
        mult: Multiplicity,
    },

    Vec: struct {
        elem: *Type,
        size: ?usize, // dependent
    },

    Channel: struct {
        proto: *Protocol,
        mult: Multiplicity,
    },
};

pub const TypedExpr = struct {
    ty: *Type,
};

pub fn typecheck(expr: anytype) !TypedExpr {
    // Stub: HM + QTT core
    return TypedExpr{ .ty = &Type.Int };
}
