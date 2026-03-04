const std = @import("std");
const core = @import("core");
const hub = @import("hub");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Fix du leak du chemin
    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);
    std.log.info("Exécution depuis : {s}", .{exe_path});

    const source = 
        \\n := 100
        \\forall i from 1 to n step 2 : a[i] := i
    ;

    // 1. Lexing
    var my_lexer = core.Lexer.init(source);
    const tokens = try my_lexer.tokenize(allocator);
    defer allocator.free(tokens);

    // 2. Parsing (Pratt)
    var my_parser = core.Parser.init(allocator, tokens);
    const root_node = try my_parser.parse();
    defer root_node.deinit(allocator);

    // 3. Projection FORTH
    var projector = hub.Projector.init(allocator);
    const forth_code = try projector.toForth(root_node);
    defer allocator.free(forth_code);

    // 4. Projection FORTRAN
    const fortran_code = try projector.toFortran(root_node);
    defer allocator.free(fortran_code);

    std.log.info("Source Heaven  : {s}", .{source});
    std.log.info("Code FORTH     : {s}", .{forth_code});
    std.log.info("Code FORTRAN   : {s}", .{fortran_code});
}
