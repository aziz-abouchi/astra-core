const std = @import("std");
const EGraph = @import("saturation/egraph.zig");
const Mirror = @import("saturation/mirror.zig");
const Brain = @import("neural/inference.zig").Brain;
const WebServer = @import("forge/web_server.zig");

const fs = std.fs;
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

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: astra <source> [--serve]\n", .{});
        return;
    }

    // --- DETECTION DU MODE SERVEUR ---
    var is_serving = false;
    for (args) |arg| {
        if (std.mem.eql(u8, arg, "--serve")) {
            is_serving = true;
            break;
        }
    }

    // --- PHASE 1 : INITIALISATION DES COMPOSANTS ---
    var egraph = EGraph.EGraph.init(allocator);
    defer egraph.deinit();

    // Initialisation du Miroir
    var mirror = try Mirror.MirrorEngine.init(allocator, "core.hvn");
    
    // Initialisation du Cerveau (IA)
    const brain: ?Brain = Brain.init("weights/astra_brain.bin") catch null;

    // --- PHASE 2 : LECTURE ET PARSING ---
    const input_path = args[1];
    var source: []u8 = undefined;
    if (std.mem.endsWith(u8, input_path, ".hvn")) {
        source = try std.fs.cwd().readFileAlloc(allocator, input_path, 1024 * 1024);
    } else {
        source = try allocator.dupe(u8, input_path);
    }
    defer allocator.free(source);

    const root_id = try Lens.heaven.parse(allocator, &egraph, source);

    // --- PHASE 3 : SATURATION ASSISTÉE ---
    if (is_serving) {
        const server_thread = try std.Thread.spawn(.{}, WebServer.startServer, .{&egraph});
        server_thread.detach();
    }

    var gupi = GupiModule.GUPI{};
    
    try mirror.applyRules(&egraph); 
    
    if (brain) |b| {
        b.guideSaturation(&egraph);
    }

    try gupi.meditate(&egraph);
    try gupi.saturate(&egraph, root_id);

    // --- PHASE 4 : GÉNÉRATION DE LA FLOTTE ---
    try processProject(allocator, &egraph, root_id);
    
    std.debug.print("[Astra]: Compilation et Preuves terminées.\n", .{});

    // --- BLOCAGE FINAL POUR LE VISUALISEUR ---
    if (is_serving) {
        std.debug.print("\n--- VISUALISEUR ASTRA ACTIF ---\n", .{});
        std.debug.print("URL: http://localhost:8080\n", .{});
        std.debug.print("Appuyez sur 'Entrée' pour fermer Astra...\n", .{});
        
        // Utilisation de std.posix pour un blocage bas niveau sans std.io
        var buf: [1]u8 = undefined;
        _ = std.posix.read(std.posix.STDIN_FILENO, &buf) catch 0;
        
        std.debug.print("[Astra]: Fermeture du serveur...\n", .{});
    }
}

pub fn processProject(allocator: std.mem.Allocator, eg: *EGraph.EGraph, root_id: EGraph.EClassId) !void {
    try fs.cwd().makePath("output");
    const targets = std.enums.values(Forge.Target);
    
    for (targets) |target| {
        var fb = FixedBuffer.init();
        Forge.emit(target, eg, root_id, &fb);
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
        .zig => "zig",
        .rust => "rs",
        .fortran => "f90",
        .julia => "jl",
        .python => "py",
        .javascript => "js",
        .racket => "rkt",
        else => @tagName(t), 
    };
}
