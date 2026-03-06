const EGraph = @import("../saturation/egraph.zig");
const Main = @import("../main.zig");

pub fn emit(egraph: *EGraph.EGraph, id: EGraph.EClassId, buf: *Main.FixedBuffer) void {
    _ = egraph; _ = id;
    buf.print("// Code bientôt disponible\n", .{});
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
