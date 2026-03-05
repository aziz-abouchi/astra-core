pub const Domain = enum {
    nat_star, // ℕ* : {1, 2, 3, ...}
    nat,      // ℕ  : {0, 1, 2, ...}
    integer,  // ℤ
    real,     // ℝ
    
    pub fn includes(self: Domain, other: Domain) bool {
        // Logique d'inclusion (ex: ℕ* est inclus dans ℕ)
        return switch (self) {
            .real => true,
            .integer => other != .real,
            .nat => (other == .nat or other == .nat_star),
            .nat_star => (other == .nat_star),
        };
    }
};
