const std = @import("std");
const Astra = @import("core/hub.zig");
const Projector = @import("hub/projector.zig").Projector;
const Checker = @import("core/checker.zig").Checker;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

//    const source = "∀ x ∈ ℕ* : x! ≥ 1";
//    const source = "∀ i ∈ ℕ : v[i] ≥ 0";
//    const source = "∀ x ∈ {1, 5, 42} : x! ≥ 1";
//    const source = "∀ x ∈ {-5, 2, -10} : |x| ≥ 0";
//    const source = "∀ x ∈ {0, 3.14} : sin(x) = 0";
    const source = "∀ x, y ∈ ℕ : max(x, y) ≥ x";

    // 1. Parsing
    const ast_root = Astra.parse(allocator, source) catch |err| {
        std.debug.print("ERREUR de Parsing : {any}\n", .{err});
        return;
    };
    defer ast_root.deinit(allocator);

    // 2. Type Checking (NOUVEAU)
    var checker = Checker.init(allocator);
    defer checker.deinit();
    _ = try checker.check(ast_root);

    // Mermaid
    const diagram = try Astra.generateDoc(allocator, ast_root);
    defer allocator.free(diagram);
    std.debug.print("--- Mermaid ---\n{s}\n", .{diagram});

    // Projecteurs
    var proj = Projector.init(allocator);
    const langs = [_][]const u8{ "heaven", "fortran", "forth" };

    for (langs) |lang| {
        var target = try proj.getTarget(lang);
        const code = try target.emitFn(target.ptr, ast_root);
        defer allocator.free(code);
        std.debug.print("\n[{s}]\n{s}\n", .{lang, code});
        target.deinitFn(target.ptr);
    }
}
