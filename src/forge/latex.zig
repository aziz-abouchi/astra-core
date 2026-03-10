const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const FixedBuffer = @import("../main.zig").FixedBuffer;
const Units = @import("../saturation/egraph.zig").Units;

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |h| buf.print("x_{{ {x:0>2} }}", .{h[0]}),
        .Operation => |op| {
            if (op.op == .Mul) {
                emit(eg, op.left, buf);
                buf.print(" \\cdot ", .{});
                emit(eg, op.right, buf);
            } else {
                buf.print("(", .{});
                emit(eg, op.left, buf);
                buf.print(" + ", .{});
                emit(eg, op.right, buf);
                buf.print(")", .{});
            }
        },
        else => buf.print("/* concept complexe */{any}", .{node}),
    }
}

fn formatUnitsLatex(u: Units) []const u8 {
    _ = u;
    // Logique pour transformer {m:1, l:2, t:-2} en "kg \cdot m^2 \cdot s^{-2}"
    // ...
}

pub fn generateProofReport(eg: *EGraph, target_id: EClassId) !void {
    _ = target_id;
    var file = try std.fs.cwd().createFile("output/proof.tex", .{});
    defer file.close();

    const writer = file.writer();
    try writer.print("\\documentclass{{article}}\n\\usepackage{{amsmath}}\n\\begin{{document}}\n", .{});
    try writer.print("\\section*{{Démonstration Astra de la Cohérence Physique}}\n", .{});
    try writer.print("\\begin{{align*}}\n", .{});

    // Parcours des étapes de réduction de GUPI
    for (eg.history.items) |step| {
        try writer.print("& \\text{{{s}}} \\implies {d} \\cdot 10^{{{d}}} \\, \\text{{{s}}} \\\\\n", .{
            step.reason.Axiom,
            eg.nodes[step.id2].Scalar.mantissa,
            eg.nodes[step.id2].Scalar.exponent,
            formatUnitsLatex(eg.nodes[step.id2].Scalar.unit),
        });
    }

    try writer.print("\\end{{align*}}\n\\end{{document}}", .{});
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
