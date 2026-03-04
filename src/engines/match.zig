const std = @import("std");
const ast = @import("core");
const unify = @import("unify.zig");

pub const Matcher = struct {
    allocator: std.mem.Allocator,

    pub fn matchPattern(self: *Matcher, pattern: *ast.Node, value: *ast.Node) !bool {
        var unifier = unify.Unifier.init(self.allocator);
        defer unifier.deinit();

        // Si l'unification réussit, le pattern correspond à la valeur
        unifier.unify(pattern, value) catch |err| {
            if (err == unify.UnifyError.MismatchedConstants or err == unify.UnifyError.MismatchedKinds) {
                return false;
            }
            return err;
        };
        
        return true;
    }
};
