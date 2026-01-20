const std = @import("std");
const EGraph = @import("../core/egraph.zig").EGraph;
const Env = @import("env.zig").Env;
const Pattern = @import("../parser/pattern.zig").Pattern;
const symFromStr = @import("../core/node.zig").symFromStr;

fn cloneEnv(gpa: std.mem.Allocator, e: *Env) !Env {
    var n = try Env.init(gpa);
    var it = e.map.iterator();
    while (it.next()) |kv| { try n.map.put(gpa, kv.key_ptr.*, kv.value_ptr.*); }
    return n;
}

fn matchAtEClass(gpa: std.mem.Allocator, eg: *EGraph, pid: u32, pat: Pattern, env_in: *Env, out_matches: *std.ArrayList(Env)) !void {
    const rid = eg.uf.find(pid);
    const cls = eg.classes.items[rid] orelse return;
    for (cls.nodes.items) |en| {
        var env = try cloneEnv(gpa, env_in);
        const ok = try matchENode(gpa, eg, en, pat, &env);
        if (ok) try out_matches.append(env) else env.deinit();
    }
}

fn matchENode(gpa: std.mem.Allocator, eg: *EGraph, en: anytype, pat: Pattern, env: *Env) !bool {
    switch (pat) {
        .Var => |_| return true,
        .App => |a| {
            const psym = try symFromStr(a.sym);
            if (en.sym != psym) return false;
            if (a.args.len != en.children.len) return false;
            var i: usize = 0;
            while (i < a.args.len) : (i += 1) {
                const child_eclass = eg.uf.find(en.children[i]);
                switch (a.args[i]) {
                    .Var => |vn| {
                        if (env.get(vn)) |old| {
                            if (old != child_eclass) return false;
                        } else try env.put(gpa, vn, child_eclass);
                    },
                    .App => |_| {
                        var submatches = std.ArrayList(Env).init(gpa);
                        defer submatches.deinit();
                        var tmp_env = try cloneEnv(gpa, env);
                        defer tmp_env.deinit();
                        try matchAtEClass(gpa, eg, child_eclass, a.args[i], &tmp_env, &submatches);
                        if (submatches.items.len == 0) return false;
                        var chosen = submatches.items[0];
                        env.*.deinit(); env.* = chosen;
                    },
                }
            }
            return true;
        },
    }
}

pub fn findMatches(gpa: std.mem.Allocator, eg: *EGraph, pat: Pattern) ![]Env {
    var outs = std.ArrayList(Env).init(gpa);
    var env0 = try Env.init(gpa);
    defer env0.deinit();
    var i: usize = 0;
    while (i < eg.classes.items.len) : (i += 1) {
        if (eg.classes.items[i] == null) continue;
        try matchAtEClass(gpa, eg, @intCast(u32, i), pat, &env0, &outs);
    }
    return try outs.toOwnedSlice();
}
