const std = @import("std");

pub const Budget = struct {
    max_cpu_ns: u64,       // nanosecondes CPU autorisées par message
    max_mem_bytes: usize,  // mémoire allouée par message
    max_energy_j: f64,     // énergie estimée par message (optionnel)
};
