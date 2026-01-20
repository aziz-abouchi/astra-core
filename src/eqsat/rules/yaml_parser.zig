const std = @import("std");
const Rule = @import("rule.zig").Rule;

pub fn loadRules(gpa: std.mem.Allocator, path: []const u8) ![]Rule {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const bytes = try file.readToEndAlloc(gpa, 1 << 20);
    defer gpa.free(bytes);

    var list = std.ArrayList(Rule).init(gpa);

    var it = std.mem.tokenizeAny(u8, bytes, "\n");
    var cur_name: ?[]const u8 = null;
    var cur_lhs:  ?[]const u8 = null;
    var cur_rhs:  ?[]const u8 = null;
    var cur_when_items = std.ArrayList([]const u8).init(gpa);

    while (it.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " \t");
        if (line.len == 0) continue;
        if (std.mem.startsWith(u8, line, "- name:")) {
            if (cur_name) |n| if (cur_lhs) |l| if (cur_rhs) |r| {
                const when_slice = try cur_when_items.toOwnedSlice();
                try list.append(.{ .name = n, .lhs = l, .rhs = r, .when = when_slice });
                cur_when_items = std.ArrayList([]const u8).init(gpa);
            }
            cur_name = std.mem.trim(u8, line[7..], " \t");
            cur_lhs = null; cur_rhs = null;
            continue;
        }
        if (std.mem.startsWith(u8, line, "lhs:")) { cur_lhs = std.mem.trim(u8, line[4..], " \t\""); continue; }
        if (std.mem.startsWith(u8, line, "rhs:")) { cur_rhs = std.mem.trim(u8, line[4..], " \t\""); continue; }
        if (std.mem.startsWith(u8, line, "when:")) {
            const open = std.mem.indexOfScalar(u8, line, '[') orelse continue;
            const close = std.mem.indexOfScalar(u8, line, ']') orelse continue;
            var inside = line[open+1..close];
            var it2 = std.mem.tokenizeAny(u8, inside, ",");
            while (it2.next()) |wraw| {
                const w = std.mem.trim(u8, wraw, " \t\"");
                if (w.len > 0) try cur_when_items.append(try std.mem.dupe(gpa, u8, w));
            }
            continue;
        }
    }
    if (cur_name) |n| if (cur_lhs) |l| if (cur_rhs) |r| {
        const when_slice = try cur_when_items.toOwnedSlice();
        try list.append(.{ .name = n, .lhs = l, .rhs = r, .when = when_slice });
    }

    return try list.toOwnedSlice();
}
