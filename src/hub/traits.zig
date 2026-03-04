const std = @import("std");

pub const MemoryModel = enum {
    manual,    // Zig, C, Fortran, Forth
    arc,       // Nim, Rust (Reference Counting)
    gc,        // PHP, JS, Java, Julia, Erlang
    linear,    // Pony (Capability-based)
};

pub const ConcurrencyStyle = enum {
    threads,   // Zig, C, Fortran (Shared Memory)
    actors,    // Erlang, Pony (Message Passing)
    single,    // JS (Event Loop), Forth
};

pub const TypeStrictness = enum {
    dependent, // Lean 4, Coq, Agda, Idris
    strong,    // Zig, Nim, Rust, Fortran
    dynamic,   // PHP, JS, Julia
};

pub const LanguageTrait = struct {
    name: []const u8,
    memory: MemoryModel,
    concurrency: ConcurrencyStyle,
    types: TypeStrictness,
    
    // Capacités spécifiques
    has_simd: bool,          // Pour le Vectoriseur
    has_macros: bool,        // Pour l'Homoiconicité
    has_tail_call: bool,     // Pour la récursion équationnelle
    has_dependent_types: bool, // Pour les preuves
};

// Exemple pour Forth
pub const ForthTrait = LanguageTrait{
    .name = "Forth",
    .memory = .manual,
    .concurrency = .single,
    .has_simd = false,
    .has_tail_call = true,
};
