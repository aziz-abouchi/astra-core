pub const Type = enum {
    integer,
    float,
    boolean,
    set,
    domain, // Pour ℕ, ℝ, etc.
    invalid,
    void,
};
