const std = @import("std");

pub const Sym = enum {
    Map, Filter, Fold, Window, Compose, And, Add, Mul, Const, Var, Zip, Map2,
};

pub fn symFromStr(s: []const u8) !Sym {
    if (std.ascii.eqlIgnoreCase(s, "map")) return .Map;
    if (std.ascii.eqlIgnoreCase(s, "filter")) return .Filter;
    if (std.ascii.eqlIgnoreCase(s, "fold")) return .Fold;
    if (std.ascii.eqlIgnoreCase(s, "window")) return .Window;
    if (std.ascii.eqlIgnoreCase(s, "compose")) return .Compose;
    if (std.ascii.eqlIgnoreCase(s, "and")) return .And;
    if (std.ascii.eqlIgnoreCase(s, "add")) return .Add;
    if (std.ascii.eqlIgnoreCase(s, "mul")) return .Mul;
    if (std.ascii.eqlIgnoreCase(s, "const")) return .Const;
    if (std.ascii.eqlIgnoreCase(s, "var")) return .Var;
    if (std.ascii.eqlIgnoreCase(s, "zip")) return .Zip;
    if (std.ascii.eqlIgnoreCase(s, "map2")) return .Map2;
    return error.UnknownSymbol;
}

pub const ENode = struct {
    sym: Sym,
    children: []u32,
};

pub const Node = ENode;
