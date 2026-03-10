const std = @import("std");

pub const Vec3 = struct {
    x: f64, y: f64, z: f64,

    pub fn smul(s: f64, v: Vec3) Vec3 {
        return .{ .x = s * v.x, .y = s * v.y, .z = s * v.z };
    }
};

pub fn printVec3(v: Vec3) void {
    std.debug.print("[{d},{d},{d}]\n", .{ v.x, v.y, v.z });
}
