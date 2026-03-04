const std = @import("std");
const ast = @import("core");

pub const Strategy = struct {
    backend_flags: []const u8,
    optimization_level: u8,
};

pub const AIAdvisor = struct {
    pub fn advise(self: *AIAdvisor, node: ast.Node) !Strategy {
        _ = self;
        _ = node;
        return Strategy{
            .backend_flags = "default",
            .optimization_level = 2,
        };
    }
};
