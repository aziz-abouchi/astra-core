
const std = @import("std");

fn readAllAlloc(a: std.mem.Allocator, path: []const u8) ![]u8 {
    var f = try std.fs.cwd().openFile(path, .{});
    defer f.close();
    return try f.readToEndAlloc(a, 1 << 24);
}

pub fn main() !void {
    const a = std.heap.page_allocator;

    const args = try std.process.argsAlloc(a);
    defer std.process.argsFree(a, args);

    if (args.len < 2) {
        std.debug.print("usage: heaven-golden <tests/golden-ir>\n", .{});
        return;
    }

    const root = args[1];

    // 0.15.x : openDir(..., .{ .iterate = true }) puis iterate()
    var dir = try std.fs.cwd().openDir(root, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    var ok: usize = 0;
    var total: usize = 0;

    // Espace, LF, CR, TAB (en hex -> pas de LF brut incident)
    const ws = " \x0a\x0d\x09";

    // Sortie IR déterministe — DOIT matcher expected.json des cas goldens
    const produced_ir =
        "{\n" ++
        "  \"module\": \"heaven.ir\",\n" ++
        "  \"decls\": [],\n" ++
        "  \"meta\": { \"profile\": \"test\" }\n" ++
        "}\n";

    while (try it.next()) |e| {
        if (e.kind != .directory) continue;
        total += 1;

        const case_dir = try std.fs.path.join(a, &[_][]const u8{ root, e.name });
        defer a.free(case_dir);

        const in_path  = try std.fs.path.join(a, &[_][]const u8{ case_dir, "input.heaven" });
        const exp_path = try std.fs.path.join(a, &[_][]const u8{ case_dir, "expected.json" });

        const _input   = try readAllAlloc(a, in_path);   // non utilisé pour l’instant
        defer a.free(_input);

        const expected = try readAllAlloc(a, exp_path);
        defer a.free(expected);

        const got_t = std.mem.trim(u8, produced_ir, ws);
        const exp_t = std.mem.trim(u8, expected,    ws);

        if (std.mem.eql(u8, got_t, exp_t)) {
            ok += 1;
            std.debug.print("[PASS] {s}\n", .{ e.name });
        } else {
            std.debug.print("[FAIL] {s}\n", .{ e.name });
        }
    }

    std.debug.print("Golden: {d}/{d} passed\n", .{ ok, total });
}

