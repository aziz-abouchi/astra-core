const std = @import("std");
const fs = std.fs;
const EGraph = @import("saturation/egraph.zig");
const Lens = @import("lens/mod.zig");
const Forge = @import("forge/mod.zig");
const GupiModule = @import("saturation/gupi.zig");

// Verrou pour les communications SCUTTLE
var log_mutex = std.Thread.Mutex{};

pub const FixedBuffer = struct {
    data: [4096]u8 = undefined,
    pos: usize = 0,
    pub fn init() FixedBuffer { return .{}; }
    pub fn reset(self: *FixedBuffer) void { self.pos = 0; } 
    
    pub fn print(self: *FixedBuffer, comptime fmt: []const u8, args: anytype) void {
        const res = std.fmt.bufPrint(self.data[self.pos..], fmt, args) catch return;
        self.pos += res.len;
    }
    pub fn getSlice(self: *FixedBuffer) []const u8 { return self.data[0..self.pos]; }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // 1. GUPI écoute les arguments du Bob (l'utilisateur)
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: astra <expression> [--fast | --deep]\n", .{});
        return;
    }

    const input_expr = args[1]; // Ta formule mathématique
    std.debug.print("[Astra-IO]: Signal reçu : \"{s}\"\n", .{input_expr});
    
    var egraph = EGraph.EGraph.init(allocator);
    defer egraph.deinit();

    // 2. On passe l'input choisi au Lens
    const root_id = try Lens.math.parse(allocator, &egraph, input_expr);

    // 2. Méditation et Saturation de GUPI
    var gupi = GupiModule.GUPI{};
    try gupi.meditate(&egraph);

    // 3. Traitement du projet (Génération physique des fichiers)
    try processProject(allocator, &egraph, root_id);

    // 4. Affichage de confirmation synchronisé (Optionnel, juste pour le style)
    std.debug.print("[GUPI]: Lancement de la réplication massive...\n", .{});
    const targets = std.enums.values(Forge.Target);
    for (targets) |target| {
        std.debug.print("[{s}]: Fichier prêt.\n", .{@tagName(target)});
    }

    std.debug.print("[GUPI]: Flotte synchronisée. Fichiers générés dans ./output/\n", .{});
}

pub fn processProject(allocator: std.mem.Allocator, eg: *EGraph.EGraph, root_id: EGraph.EClassId) !void {
    try fs.cwd().makePath("output");
    const targets = std.enums.values(Forge.Target);
    
    for (targets) |target| {
        var fb = FixedBuffer.init();
        Forge.emit(target, eg, root_id, &fb);
        
        // On ajoute un retour à la ligne pour que 'cat' respire
        fb.print("\n", .{}); 

        const ext = getExtension(target);
        const filename = try std.fmt.allocPrint(allocator, "output/kernel.{s}", .{ext});
        defer allocator.free(filename);
        
        const file = try fs.cwd().createFile(filename, .{});
        defer file.close();
        try file.writeAll(fb.getSlice());
    }
}

fn getExtension(t: Forge.Target) []const u8 {
    return switch (t) {
        // Cas particuliers (les exceptions à la règle)
        .zig => "zig",
        .rust => "rs",
        .fortran => "f90",
        .julia => "jl",
        .python => "py",
        .javascript => "js",
        .racket => "rkt",
        // Cas automatique : on transforme le nom de l'enum en string !
        else => @tagName(t), 
    };
}

fn runParallelForge(wg: *std.Thread.WaitGroup, target: Forge.Target, eg: *EGraph.EGraph, id: EGraph.EClassId) void {
    defer wg.finish();
    var fb = FixedBuffer.init();
    Forge.emit(target, eg, id, &fb);
    log_mutex.lock();
    defer log_mutex.unlock();
    std.debug.print("[{s}]: Fichier prêt.\n", .{@tagName(target)});
}
