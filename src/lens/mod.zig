const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

// Importation de la constellation des Front-ends
pub const math    = @import("math.zig");
pub const forth   = @import("forth.zig");
pub const fortran = @import("fortran.zig");
pub const python  = @import("python.zig");
pub const lean    = @import("lean.zig");
pub const latex   = @import("latex.zig");
pub const heaven  = @import("heaven.zig");
pub const zig     = @import("zig.zig");
pub const c       = @import("c.zig");
pub const wat     = @import("wat.zig");
pub const qbe     = @import("qbe.zig");
pub const pony    = @import("pony.zig");
pub const idris   = @import("idris.zig");
pub const llvm    = @import("llvm.zig");
pub const rust    = @import("rust.zig");

pub const SourceLang = enum {
    math, forth, fortran, python, lean, latex, heaven, zig, wat, qbe, pony, idris, llvm, c, rust,
};

pub fn parse(lang: SourceLang, allocator: std.mem.Allocator, egraph: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    return switch (lang) {
        .math    => try math.parse(allocator, egraph, input),
        .forth   => try forth.parse(allocator, egraph, input),
        .fortran => try fortran.parse(allocator, egraph, input),
        .python  => try python.parse(allocator, egraph, input),
        .lean    => try lean.parse(allocator, egraph, input),
        .latex   => try latex.parse(allocator, egraph, input),
        .heaven  => try heaven.parse(allocator, egraph, input),
        .zig     => try zig.parse(allocator, egraph, input),
        .c       => try c.parse(allocator, egraph, input),
        .wat     => try wat.parse(allocator, egraph, input),
        .qbe     => try qbe.parse(allocator, egraph, input),
        .pony    => try pony.parse(allocator, egraph, input),
        .idris   => try idris.parse(allocator, egraph, input),
        .llvm    => try llvm.parse(allocator, egraph, input),
        .rust    => try rust.parse(allocator, egraph, input),
    };
}
