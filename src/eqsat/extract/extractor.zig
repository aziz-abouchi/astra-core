const std = @import("std");
const EGraph = @import("../core/egraph.zig").EGraph;
const Profile = @import("cost.zig").Profile;
const Sym = @import("../core/node.zig").Sym;

pub const Extractor = struct {
    gpa: std.mem.Allocator,
    eg: *EGraph,
    profile: Profile,

    pub fn init(gpa: std.mem.Allocator, eg: *EGraph, profile: Profile) !Extractor { return .{ .gpa = gpa, .eg = eg, .profile = profile }; }
    pub fn deinit(self: *Extractor) void { _ = self; }

    fn symName(sym: Sym) []const u8 { return switch (sym) { .Map=>"map", .Filter=>"filter", .Fold=>"fold", .Window=>"window", .Compose=>"compose", .And=>"and", .Add=>"add", .Mul=>"mul", .Const=>"const", .Var=>"var", .Zip=>"zip", .Map2=>"map2", }; }

    pub fn extractAsSExprString(self: *Extractor, gpa: std.mem.Allocator, root: u32) ![]u8 {
        const rid = self.eg.uf.find(root);
        const cls = self.eg.classes.items[rid] orelse return gpa.dupe(u8, "(v)");
        if (cls.nodes.items.len == 0) return gpa.dupe(u8, "(v)");
        const en = cls.nodes.items[0];
        var buf = std.ArrayList(u8).init(gpa); defer buf.deinit();
        try buf.writer().print("({s}", .{symName(en.sym)});
        for (en.children) |ch| { const sub = try self.extractAsSExprString(gpa, ch); defer gpa.free(sub); try buf.append(' '); try buf.appendSlice(sub); }
        try buf.append(')');
        return try buf.toOwnedSlice();
    }
};
