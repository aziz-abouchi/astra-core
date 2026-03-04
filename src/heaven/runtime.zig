const std = @import("std");
const Node = @import("ast.zig").Node;

pub fn eval(node: *Node) i64 {
    return switch (node.*) {
        .Int => |v| v,
        .Ident => |_| 0,
        .Call => |c| {
            if (std.mem.eql(u8, c.name, "inc"))
                return eval(c.arg) + 1;

            if (std.mem.eql(u8, c.name, "double"))
                return eval(c.arg) * 2;

            return 0;
        },
    };
}
