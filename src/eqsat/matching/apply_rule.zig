const std = @import("std");
const EGraph = @import("../core/egraph.zig").EGraph;
const Rule = @import("../rules/rule.zig").Rule;
const lex = @import("../parser/lexer.zig").lex;
const parseS = @import("../parser/sexpr.zig").parse;
const toPat = @import("../parser/pattern.zig").fromSExpr;
const Pattern = @import("../parser/pattern.zig").Pattern;
const Env = @import("env.zig").Env;
const symFromStr = @import("../core/node.zig").symFromStr;

fn buildFromPattern(gpa: std.mem.Allocator, eg: *EGraph, pat: Pattern, env: *Env) !u32 {
    return switch (pat) { .Var => |v| env.get(v) orelse return error.UnboundVar, .App => |a| blk: { const sym = try symFromStr(a.sym); var child_ids = try gpa.alloc(u32, a.args.len); var i: usize = 0; while (i < a.args.len) : (i += 1) child_ids[i] = try buildFromPattern(gpa, eg, a.args[i], env); const id = try eg.addENode(.{ .sym = sym, .children = child_ids }); gpa.free(child_ids); break :blk id; }, };
}

pub fn applyRule(gpa: std.mem.Allocator, eg: *EGraph, rule: Rule) !bool {
    const toks_lhs = try lex(gpa, rule.lhs); defer gpa.free(toks_lhs);
    const sx_lhs = try parseS(gpa, toks_lhs); defer freeSExpr(gpa, sx_lhs);
    const pat_lhs = try toPat(gpa, sx_lhs); defer freePat(gpa, pat_lhs);

    const toks_rhs = try lex(gpa, rule.rhs); defer gpa.free(toks_rhs);
    const sx_rhs = try parseS(gpa, toks_rhs); defer freeSExpr(gpa, sx_rhs);
    const pat_rhs = try toPat(gpa, sx_rhs); defer freePat(gpa, pat_rhs);

    var changed = false;
    var matches = try @import("matcher.zig").findMatches(gpa, eg, pat_lhs);
    defer { for (matches) |*e| e.deinit(); gpa.free(matches); }

    for (matches) |*env| {
        var union_target: ?u32 = null; var it = env.map.iterator(); if (it.next()) |kv| union_target = kv.value_ptr.*; if (union_target == null) continue;
        const rhs_id = try buildFromPattern(gpa, eg, pat_rhs, env);
        _ = try eg.union(union_target.?, rhs_id);
        changed = true;
    }
    return changed;
}

fn freeSExpr(gpa: std.mem.Allocator, sx: anytype) void { switch (sx) { .Atom => |_| {}, .List => |ls| gpa.free(ls), } }
fn freePat(gpa: std.mem.Allocator, p: Pattern) void { switch (p) { .Var => |_| {}, .App => |a| gpa.free(a.args), } }
