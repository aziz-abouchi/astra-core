const traits = @import("../traits.zig");

pub const ForthTrait = traits.LanguageTrait{
    .name = "Forth",
    .memory = .manual,
    .concurrency = .single,
    .types = .dynamic, // Forth ne vérifie rien au runtime
    .has_simd = false,
    .has_macros = true, // Forth est ultra-extensible
    .has_tail_call = true,
    .has_dependent_types = false,
};
