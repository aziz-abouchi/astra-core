const std = @import("std");
const Pass = @import("eqsat_pass");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const air = "{\"nodes\":[{\"id\":1,\"op\":\"Var\",\"name\":\"s\"},{\"id\":2,\"op\":\"Var\",\"name\":\"g\"},{\"id\":3,\"op\":\"Var\",\"name\":\"f\"},{\"id\":4,\"op\":\"Map\",\"children\":[2,1]},{\"id\":5,\"op\":\"Map\",\"children\":[3,4]}],\"root\":5}";
    const out = try Pass.runFromAirJson(alloc, air, "rules/rules_v1.yaml", .{}); defer alloc.free(out);
    std.debug.print("Optimized form: {s}\n", .{out});
}
