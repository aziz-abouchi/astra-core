const std = @import("std");
const Node = @import("node.zig").ENode;
const EClass = @import("eclass.zig").EClass;
const UnionFind = @import("union_find.zig").UnionFind;
const Key = @import("hashcons.zig").Key;
const KeyCtx = @import("hashcons.zig").KeyCtx;

pub const EGraph = struct {
    gpa: std.mem.Allocator,
    uf: UnionFind,
    classes: std.ArrayList(?*EClass),
    cons: std.HashMap(Key, u32, KeyCtx, 80),

    pub fn init(gpa: std.mem.Allocator) !EGraph {
        return .{ .gpa = gpa, .uf = try UnionFind.init(gpa), .classes = std.ArrayList(?*EClass).init(gpa), .cons = std.HashMap(Key, u32, KeyCtx, 80).init(gpa) };
    }

    pub fn deinit(self: *EGraph) void {
        var i: usize = 0;
        while (i < self.classes.items.len) : (i += 1) {
            if (self.classes.items[i]) |cls| { cls.deinit(); self.gpa.destroy(cls); }
        }
        self.classes.deinit();
        self.uf.deinit();
        self.cons.deinit();
    }

    fn ensureClass(self: *EGraph) !u32 {
        const id = try self.uf.make();
        const cls = try self.gpa.create(EClass);
        cls.* = try EClass.init(self.gpa, id);
        while (self.classes.items.len <= id) try self.classes.append(null);
        self.classes.items[id] = cls;
        return id;
    }

    fn canonicalizeChildren(self: *EGraph, children: []const u32) ![]u32 {
        var out = try self.gpa.alloc(u32, children.len);
        var i: usize = 0;
        while (i < children.len) : (i += 1) out[i] = self.uf.find(children[i]);
        return out;
    }

    pub fn addENode(self: *EGraph, n: Node) !u32 {
        const canon_children = try self.canonicalizeChildren(n.children);
        defer self.gpa.free(canon_children);
        const key = Key{ .sym = n.sym, .children = canon_children };
        if (self.cons.get(key)) |id| return id;
        const id = try self.ensureClass();
        const cls = self.classes.items[id].?;
        var store_children = try self.gpa.alloc(u32, canon_children.len);
        std.mem.copy(u32, store_children, canon_children);
        try cls.nodes.append(.{ .sym = n.sym, .children = store_children });
        try self.cons.put(key, id);
        return id;
    }

    pub fn union(self: *EGraph, a: u32, b: u32) !u32 {
        const ra = self.uf.find(a);
        const rb = self.uf.find(b);
        if (ra == rb) return ra;
        const root = self.uf.union(ra, rb);
        const other: u32 = if (root == ra) rb else ra;
        const cls_root = self.classes.items[root].?;
        const cls_other = self.classes.items[other].?;
        for (cls_other.nodes.items) |en| try cls_root.nodes.append(en);
        cls_other.nodes.items.len = 0;
        self.classes.items[other] = null;
        return root;
    }
};
