const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

// Imports des Back-ends
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
pub const koka    = @import("koka.zig");
pub const odin    = @import("odin.zig");
pub const carp    = @import("carp.zig");
pub const lys     = @import("lys.zig");
pub const julia   = @import("julia.zig");
pub const r       = @import("r.zig");
pub const javascript = @import("javascript.zig");
pub const php        = @import("php.zig");
pub const nim        = @import("nim.zig");
pub const racket     = @import("racket.zig");

pub const Target = enum {
    math, forth, fortran, python, lean, latex, heaven, zig, wat, qbe, pony, idris, llvm, c, rust, koka, odin, carp, lys, julia, r, javascript, php, nim, racket
};

pub fn emit(target: Target, egraph: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const best_id = egraph.getBestId(id);

    switch (target) {
        .forth   => forth.emitFull(egraph, best_id, buf),
        .fortran => fortran.emitFull(egraph, best_id, buf),
        .javascript => javascript.emitFull(egraph, best_id, buf),
        .python     => python.emitFull(egraph, best_id, buf),
        .rust       => rust.emitFull(egraph, best_id, buf),
        else => {
            const node = egraph.nodes[best_id];
            switch (node) {
                .Atomic => |name| {
                    const trimmed = std.mem.trim(u8, &name, " ");
                    buf.print("{s}", .{trimmed});
                },
                .Constant => |val| {
                    buf.print("{d}", .{val});
                },
                .Vector => |v| {
                    buf.print("vec3({d}, {d}, {d})", .{v.x, v.y, v.z});
                },
                .Operation => {
                    switch (target) {
                        .math    => math.emit(egraph, best_id, buf),
                        .lean    => lean.emit(egraph, best_id, buf),
                        .latex   => latex.emit(egraph, best_id, buf),
                        .heaven  => heaven.emit(egraph, best_id, buf),
                        .zig     => zig.emit(egraph, best_id, buf),
                        .c       => c.emit(egraph, best_id, buf),
                        .wat     => wat.emit(egraph, best_id, buf),
                        .qbe     => qbe.emit(egraph, best_id, buf),
                        .pony    => pony.emit(egraph, best_id, buf),
                        .idris   => idris.emit(egraph, best_id, buf),
                        .llvm    => llvm.emit(egraph, best_id, buf),
                        .koka    => koka.emit(egraph, best_id, buf),
                        .odin    => odin.emit(egraph, best_id, buf),
                        .carp    => carp.emit(egraph, best_id, buf),
                        .lys     => lys.emit(egraph, best_id, buf),
                        .julia   => julia.emit(egraph, best_id, buf),
                        .r       => r.emit(egraph, best_id, buf),
                        .php     => php.emit(egraph, best_id, buf),
                        .nim     => nim.emit(egraph, best_id, buf),
                        .racket  => racket.emit(egraph, best_id, buf),
                        else => {}
                    }
                },
            }
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => ".", .Cross => "#",
    };
}
