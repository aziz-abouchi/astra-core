
const std = @import("std");
const Node = @import("node.zig").ENode;
const EClass = @import("eclass.zig").EClass;
const UnionFind = @import("union_find.zig").UnionFind;
const Key = @import("hashcons.zig").Key;
const KeyCtx = @import("hashcons.zig").KeyCtx;

pub const EGraph = struct {
    gpa: std.mem.Allocator,
    uf: UnionFind,
    classes: std.ArrayListUnmanaged(?*EClass),
    cons: std.HashMap(Key, u32, KeyCtx, 80),

    pub fn init(gpa: std.mem.Allocator) !EGraph {
        return .{
            .gpa = gpa,
            .uf = try UnionFind.init(gpa),
            .classes = .{}, // Unmanageds
            .cons = std.HashMap(Key, u32, KeyCtx, 80).init(gpa),
        };
    }

    pub fn deinit(self: *EGraph) void {
        for (self.classes.items) |opt| {
            if (opt) |cls| {
                cls.deinit();
                self.gpa.destroy(cls);
            }
        }
        self.classes.deinit(self.gpa);
        self.uf.deinit();
        self.cons.deinit();
    }

    fn ensureClass(self: *EGraph) !u32 {
        const id = try self.uf.make();
        const cls = try self.gpa.create(EClass);
        cls.* = try EClass.init(self.gpa, id);

        while (self.classes.items.len <= id)
            try self.classes.append(self.gpa, null);

        self.classes.items[id] = cls;
        return id;
    }

    fn canonicalizeChildren(self: *EGraph, children: []const u32) ![]u32 {
        var out = try self.gpa.alloc(u32, children.len);
        for (children, 0..) |c, i|
            out[i] = self.uf.find(c);
        return out;
    }

    pub fn addENode(self: *EGraph, n: Node) !u32 {
        const canon = try self.canonicalizeChildren(n.children);
        defer self.gpa.free(canon);

        const key = Key{ .sym = n.sym, .children = canon };
        if (self.cons.get(key)) |eid|
            return eid;

        const eid = try self.ensureClass();
        const cls = self.classes.items[eid].?;

        const stored = try self.gpa.alloc(u32, canon.len);
        std.mem.copy(u32, stored, canon);

        try cls.nodes.append(.{ .sym = n.sym, .children = stored });
        try self.cons.put(key, eid);
        return eid;
    }

    pub fn mergeClasses(self: *EGraph, a: u32, b: u32) !u32 {
        const ra = self.uf.find(a);
        const rb = self.uf.find(b);
        if (ra == rb) return ra;

	const root = UnionFind.unite(&self.uf, ra, rb);

        const other: u32 = if (root == ra) rb else ra;

        const root_cls = self.classes.items[root].?;
        const other_cls = self.classes.items[other].?;

        for (other_cls.nodes.items) |en|
            try root_cls.nodes.append(en);

        other_cls.nodes.items.len = 0;
        self.classes.items[other] = null;

        return root;
    }
};
