const std = @import("std");
const memory = @import("memory.zig");
const io = @import("io.zig");
const parser = @import("parser.zig");
const evaler = @import("eval.zig");

const testFile = "../heaven_src/test_lot3_3.heaven";

pub fn main() void {
    io.println("HEAVEN minimal runtime start");

    const heaven_code = io.readFile( testFile );
    if (heaven_code == null) {
        io.println("Cannot read testFile");
        return;
    }

    const ast = parser.parse(heaven_code.?);
    evaler.eval(ast);

    io.println("HEAVEN bootstrap complete");
}

