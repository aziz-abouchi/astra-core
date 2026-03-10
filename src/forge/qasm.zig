pub fn generateQASM(eg: *EGraph, root: EClassId) !void {
    const val = eg.getBestValue(root); // Notre angle calculé
    var file = try std.fs.cwd().createFile("output/kernel.qasm", .{});
    const w = file.writer();

    try w.writeAll("OPENQASM 2.0;\ninclude \"qelib1.inc\";\n");
    try w.writeAll("qreg q[1];\n");
    // On injecte la valeur physique d'Astra comme paramètre de porte
    try w.print("rz({d}) q[0];\n", .{val.toF64()});
    try w.writeAll("measure q[0];\n");
}
