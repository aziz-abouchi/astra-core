const std = @import("std");
const ast = @import("../core/ast.zig");
const Target = @import("target.zig").Target;
const ForthTarget = @import("targets/forth.zig").ForthTarget;
const FortranTarget = @import("targets/fortran.zig").FortranTarget;
const HeavenTarget = @import("targets/heaven.zig").HeavenTarget;

pub const Projector = struct {
    allocator: std.mem.Allocator,
    pub fn init(allocator: std.mem.Allocator) Projector { return .{ .allocator = allocator }; }

    pub fn getTarget(self: *Projector, lang: []const u8) !Target {
        if (std.mem.eql(u8, lang, "forth")) {
            const t = try self.allocator.create(ForthTarget);
            t.* = ForthTarget.init(self.allocator);
            return t.asTarget();
        } else if (std.mem.eql(u8, lang, "fortran")) {
            const t = try self.allocator.create(FortranTarget);
            t.* = FortranTarget.init(self.allocator);
            return t.asTarget();
        } else if (std.mem.eql(u8, lang, "heaven")) {
            const t = try self.allocator.create(HeavenTarget);
            t.* = HeavenTarget.init(self.allocator);
            return t.asTarget();
        }
        return error.UnknownTarget;
    }
};
