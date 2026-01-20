const std = @import("std");
const Node = @import("core/node.zig").Node;
const Sym = @import("core/node.zig").Sym;
const EGraph = @import("core/egraph.zig").EGraph;
const Rule = @import("rules/rule.zig").Rule;
const YamlRules = @import("rules/yaml_parser.zig");
const Apply = @import("matching/apply_rule.zig");
const Extractor = @import("extract/extractor.zig").Extractor;
const Cost = @import("extract/cost.zig");

pub const RunProfile = enum { default, local, distrib };
pub const RunConfig = struct { profile: RunProfile = .default, max_fixpoint_iters: usize = 8, max_saturation_passes: usize = 64, enable_labels: bool = true };

const AirNode = struct { id: u32, op: []const u8, children: ?[]const u32 = null, name: ?[]const u8 = null, value_i64: ?i64 = null };
const AirModule = struct { nodes: []AirNode, root: u32 };
const LabelMap = std.AutoHashMapUnmanaged(u32, []const u8);

fn symFromOp(op: []const u8) !Sym { return @import("core/node.zig").symFromStr(op); }
fn costProfile(p: RunProfile) Cost.Profile { return switch (p) { .default => .default, .local => .local, .distrib => .distrib }; }

pub fn buildEGraphFromAirJson(gpa: std.mem.Allocator, air_json: []const u8, eg: *EGraph, label_map: *LabelMap) !u32 {
    var parsed = try std.json.parseFromSlice(AirModule, gpa, air_json, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    var id_to_class = std.AutoHashMap(u32, u32).init(gpa); defer id_to_class.deinit();
    for (parsed.value.nodes) |an| {
        const sym = try symFromOp(an.op);
        var child_ids = std.ArrayList(u32).init(gpa); defer child_ids.deinit();
        if (an.children) |chs| { for (chs) |cid| { const p = id_to_class.get(cid) orelse return error.ChildNotLowered; try child_ids.append(p.*); } }
        var n = Node{ .sym = sym, .children = try child_ids.toOwnedSlice() }; defer gpa.free(n.children);
        const eclass_id = try eg.addENode(n);
        if (sym == .Var) { if (an.name) |nm| { try label_map.put(gpa, eclass_id, try std.mem.dupe(gpa, u8, nm)); } }
        if (sym == .Const) { if (an.value_i64) |v| { var buf: [24]u8 = undefined; const s = std.fmt.integerToSlice(&buf, v, 10, .lower, .{}); try label_map.put(gpa, eclass_id, try std.mem.dupe(gpa, u8, s)); } }
        try id_to_class.put(an.id, eclass_id);
    }
    const p = id_to_class.get(parsed.value.root) orelse return error.InvalidRoot; return p.*;
}

pub fn loadRulesFromYaml(gpa: std.mem.Allocator, path: []const u8) ![]Rule { return try YamlRules.loadRules(gpa, path); }

pub fn saturate(gpa: std.mem.Allocator, eg: *EGraph, rules: []const Rule, cfg: RunConfig) !void {
    var pass_count: usize = 0; var changed_any = true; while (changed_any and pass_count < cfg.max_saturation_passes) : (pass_count += 1) { changed_any = false; for (rules) |r| { const changed = try Apply.applyRule(gpa, eg, r); if (changed) changed_any = true; } _ = cfg; }
}

pub fn extractOptimizedSExpr(gpa: std.mem.Allocator, eg: *EGraph, root_eclass: u32, profile: RunProfile) ![]u8 { var extractor = try Extractor.init(gpa, eg, costProfile(profile)); defer extractor.deinit(); return try extractor.extractAsSExprString(gpa, root_eclass); }

pub fn runFromAirJson(gpa: std.mem.Allocator, air_json: []const u8, rules_yaml_path: []const u8, cfg: RunConfig) ![]u8 {
    var eg = try EGraph.init(gpa); defer eg.deinit();
    var labels = LabelMap{}; defer { var it = labels.iterator(); while (it.next()) |e| gpa.free(e.value_ptr.*); labels.deinit(gpa); }
    const root = try buildEGraphFromAirJson(gpa, air_json, &eg, &labels);
    const rules = try loadRulesFromYaml(gpa, rules_yaml_path); defer { for (rules) |*r| r.deinit(gpa); gpa.free(rules); }
    try saturate(gpa, &eg, rules, cfg); return try extractOptimizedSExpr(gpa, &eg, root, cfg.profile);
}

// Test unitaire (Zig 0.15 raw literal)

test "EQSAT pass: map/map fusion" {
    const gpa = std.testing.allocator;

    // JSON mono-ligne : évite toute ambiguïté de raw-literal

    const air =
        "{\"nodes\":["
        ++ "{\"id\":1,\"op\":\"Var\",\"name\":\"s\"},"
        ++ "{\"id\":2,\"op\":\"Var\",\"name\":\"g\"},"
        ++ "{\"id\":3,\"op\":\"Var\",\"name\":\"f\"},"
        ++ "{\"id\":4,\"op\":\"Map\",\"children\":[2,1]},"
        ++ "{\"id\":5,\"op\":\"Map\",\"children\":[3,4]}"
        ++ "],\"root\":5}";

    const rules_path = "rules/rules_v1.yaml";
    const cfg = RunConfig{
        .profile = .default,
        .max_fixpoint_iters = 8,
        .max_saturation_passes = 64,
        .enable_labels = false,
    };

    const out = try runFromAirJson(gpa, air, rules_path, cfg);
    defer gpa.free(out);

    try std.testing.expect(std.mem.startsWith(u8, out, "(map"));
}

