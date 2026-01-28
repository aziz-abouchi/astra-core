const std = @import("std");
const Allocator = std.mem.Allocator;

pub const TypeVarId = u32;

pub const TypeVar = struct {
    id: TypeVarId,
};

pub const Type = union(enum) {
    Int,
    Bool,
    Var: TypeVar,
    Arrow: struct {
        from: *Type,
        to: *Type,
    },
};

/// ∀a b c. type
pub const Scheme = struct {
    vars: []TypeVarId,
    ty: *Type,
};

