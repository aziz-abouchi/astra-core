const std = @import("std");
const types = @import("types.zig");

const Type = types.Type;
const Scheme = types.Scheme;
const TypeVarId = types.TypeVarId;
const Allocator = std.mem.Allocator;

const PPContext = struct {
    names: std.AutoHashMap(TypeVarId, []const u8),
    next: u8 = 'a',

    fn init(alloc: Allocator) PPContext {
        return .{
            .names = std.AutoHashMap(TypeVarId, []const u8).init(alloc),
        };
    }
};

fn nameOf(ctx: *PPContext, id: TypeVarId, alloc: Allocator) []const u8 {
    if (ctx.names.get(id)) |n| return n;

    const buf = alloc.alloc(u8, 1) catch unreachable;
    buf[0] = ctx.next;
    ctx.next += 1;

    ctx.names.put(id, buf) catch unreachable;
    return buf;
}

fn ppType(t: *Type, ctx: *PPContext, alloc: Allocator) []const u8 {
    return switch (t.*) {
        .Int => "Int",
        .Bool => "Bool",
        .Var => |v| nameOf(ctx, v.id, alloc),
        .Arrow => |a| std.fmt.allocPrint(
            alloc,
            "({s} → {s})",
            .{
                ppType(a.from, ctx, alloc),
                ppType(a.to, ctx, alloc),
            },
        ) catch unreachable,
    };
}

pub fn ppScheme(s: Scheme, alloc: Allocator) []const u8 {
    var ctx = PPContext.init(alloc);
    const body = ppType(s.ty, &ctx, alloc);

    if (s.vars.len == 0) return body;

    return std.fmt.allocPrint(
        alloc,
        "∀{c}. {s}",
        .{ 'a', body },
    ) catch unreachable;
}

