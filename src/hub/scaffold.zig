const std = @import("std");
const traits = @import("traits.zig");

pub const Scaffolder = struct {
    allocator: std.mem.Allocator,

    pub fn createLanguage(self: *Scaffolder, name: []const u8, trait: traits.LanguageTrait) !void {
        // 1. Créer le dossier dans src/hub/backends/[name]
        const path = try std.fmt.allocPrint(self.allocator, "src/hub/backends/{s}", .{name});
        try std.fs.cwd().makePath(path);

        // 2. Générer le fichier de définition du Trait
        try self.generateTraitFile(name, trait);

        // 3. Générer le 'projector_impl.zig' (le traducteur d'AST)
        try self.generateBackendLogic(name);
        
        std.debug.print("Backend pour {s} initialisé avec succès !\n", .{name});
    }
};
