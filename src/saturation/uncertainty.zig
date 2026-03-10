const std = @import("std");
const egraph = @import("egraph.zig");

pub const UncertaintyLogic = struct {
    /// Propagation pour l'addition : σ = sqrt(σa² + σb²)
    pub fn add(a: egraph.Quantity, b: egraph.Quantity) f64 {
        return std.math.sqrt(std.math.pow(f64, a.uncertainty, 2) + std.math.pow(f64, b.uncertainty, 2));
    }

    /// Propagation pour la multiplication : σ_res = |res| * sqrt((σa/a)² + (σb/b)²)
    pub fn mul(a: egraph.Quantity, b: egraph.Quantity, res_val: f64) f64 {
        const rel_a = a.uncertainty / @abs(a.toF64());
        const rel_b = b.uncertainty / @abs(b.toF64());
        return @abs(res_val) * std.math.sqrt(std.math.pow(f64, rel_a, 2) + std.math.pow(f64, rel_b, 2));
    }
};
