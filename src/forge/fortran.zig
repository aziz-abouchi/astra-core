const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    buf.print("program astra_kernel\n", .{});
    buf.print("  implicit none\n", .{});
    
    // --- 1. SCAN ET DÉCLARATION DES VARIABLES ---
    // On boucle sur les nœuds pour trouver les noms uniques
    for (eg.nodes[0..eg.len]) |node| {
        switch (node) {
            .Atomic => |name| {
                const trimmed = std.mem.trim(u8, &name, " ");
                // On les déclare comme vecteurs pour supporter dot et cross
                buf.print("  real(8), dimension(3) :: {s}\n", .{trimmed});
            },
            else => {},
        }
    }
    
    buf.print("  real(8) :: res_scalar\n", .{});
    buf.print("  real(8), dimension(3) :: res_vec\n\n", .{}); 

    buf.print("  ! NOTE: L'expression ci-dessous mélange scalaire et vecteur.\n", .{});
    buf.print("  ! res_vec = ... (Le résultat final doit être cohérent)\n", .{});
    
    buf.print("  res_vec = ", .{});
    emit(eg, id, buf); 
    buf.print("\n", .{});
    
    buf.print("  print *, \"Calcul terminé.\"\n", .{});
    buf.print("contains\n", .{});
    buf.print("  pure function astra_cross_product(u, v) result(res)\n", .{});
    buf.print("    real(8), dimension(3), intent(in) :: u, v\n", .{});
    buf.print("    real(8), dimension(3) :: res\n", .{});
    buf.print("    res(1) = u(2)*v(3) - u(3)*v(2)\n", .{});
    buf.print("    res(2) = u(3)*v(1) - u(1)*v(3)\n", .{});
    buf.print("    res(3) = u(1)*v(2) - u(2)*v(1)\n", .{});
    buf.print("  end function astra_cross_product\n", .{});
    buf.print("end program astra_kernel\n", .{});
}

pub fn emit(eg: *EGraph.EGraph, id: EGraph.EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Atomic => |name| buf.print("{s}", .{std.mem.trim(u8, &name, " ")}),
        .Constant => |val| buf.print("{d}_8", .{val}), // Précision double en Fortran
        .Operation => |op| {
            switch (op.op) {
                .Dot => {
                    buf.print("dot_product(", .{});
                    emit(eg, op.left, buf);
                    buf.print(", ", .{});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
                .Cross => {
                    // Pour que ça compile, il faudrait définir cette fonction !
                    buf.print("astra_cross_product(", .{});
                    emit(eg, op.left, buf);
                    buf.print(", ", .{});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
                else => {
                    buf.print("(", .{});
                    emit(eg, op.left, buf);
                    buf.print(" {s} ", .{getSymbol(op.op)});
                    emit(eg, op.right, buf);
                    buf.print(")", .{});
                },
            }
        },
        .Vector => |v| buf.print("[{d}, {d}, {d}]", .{v.x, v.y, v.z}),
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "dot", .Cross => "cross",
    };
}
