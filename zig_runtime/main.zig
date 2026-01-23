const std = @import("std");
const memory = @import("memory.zig");
const io = @import("io.zig");
const parser = @import("parser.zig");
const evaler = @import("eval.zig");

const testFile = "../astra_src/test_lot3_3.astra";

pub fn main() void {
    io.println("ASTRA minimal runtime start");

    const astra_code = io.readFile( testFile );
    if (astra_code == null) {
        io.println("Cannot read testFile");
        return;
    }

    const ast = parser.parse(astra_code.?);
    evaler.eval(ast);

    io.println("ASTRA bootstrap complete");
}

