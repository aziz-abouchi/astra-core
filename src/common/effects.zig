const std = @import("std");

pub const EffectTag = enum {
    Display,
    Safety,
};

pub const EffectRequest = struct {
    tag: EffectTag,
    payload: []const u8,
};

// Handler utilisant les appels système directs (Descripteur 1 = stdout)
pub fn terminalHandler(req: EffectRequest) void {
    const prefix = switch (req.tag) {
        .Display => "[Astra-IO]: ",
        .Safety => "⚠️ [Astra-Alert]: ",
    };

    // Écriture du préfixe
    _ = std.posix.write(1, prefix) catch {};
    // Écriture du message
    _ = std.posix.write(1, req.payload) catch {};
    // Saut de ligne
    _ = std.posix.write(1, "\n") catch {};
}
