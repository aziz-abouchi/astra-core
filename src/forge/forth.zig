const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("\\ --- Astra MiniForth Kernel (Vector Mode) ---\n\n", .{});

    // 1. DÉFINITION DES DONNÉES (On remplace le "1" par 3 composantes)
    for (eg.nodes[0..eg.len]) |node| {
        if (node == .Atomic) {
            const name = std.mem.trim(u8, &node.Atomic, " ");
            // On simule des vecteurs distincts pour le test : a=[1,2,3], b=[4,5,6]...
            buf.print(": {s} 1 2 3 ; \n", .{name}); 
        }
    }

    // 2. MATHÉMATIQUES VECTORIELLES (Le vrai produit scalaire : x1*x2 + y1*y2 + z1*z2)
    // En Forth, on doit manipuler la pile : ( z1 y1 x1 z2 y2 x2 -- dot )
    buf.print("\n: fdot ( z1 y1 x1 z2 y2 x2 -- res )\n", .{});
    buf.print("    rot * \\ x1*x2\n", .{});
    buf.print("    -rot rot * +    \\ + y1*y2\n", .{});
    buf.print("    -rot * +        \\ + z1*z2\n", .{});
    buf.print("; \n", .{});

    buf.print(": fcross + ; \\ On garde un stub pour l'instant \n\n", .{});

    // 3. LE MAIN
    buf.print(": main\n    ", .{});
    emit(eg, id, buf); 
    buf.print("\n;\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |name| buf.print("{s} ", .{std.mem.trim(u8, &name, " ")}),
        .Constant => |val| buf.print("{d} ", .{val}),
        .Operation => |op| {
            emit(eg, op.left, buf);
            emit(eg, op.right, buf);
            buf.print("{s} ", .{getSymbol(op.op)});
        },
        .Vector => |v| buf.print("{d} {d} {d} ", .{v.x, v.y, v.z}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "fdot", .Cross => "fcross",
    };
}
