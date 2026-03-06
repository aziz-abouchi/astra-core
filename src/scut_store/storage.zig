const std = @import("std");
const Hash = @import("../common/hash.zig").Hash;

pub const AtomType = enum(u8) {
    Scalar = 0x01,
    Vector = 0x02,
    Matrix = 0x03,
};

pub const AtomValue = struct {
    tag: AtomType,
    rows: u32,
    cols: u32,
    data_ptr: [*]f64, // Référence vers le bloc de données Fortran-style
};

pub const ScutStore = struct {
    file: std.fs.File,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !ScutStore {
        const file = try std.fs.cwd().createFile(path, .{ .read = true });
        return .{ .file = file, .allocator = allocator };
    }

     pub fn put(self: *ScutStore, hash: Hash, data: []const u8) !void {
        // 1. On ferme et on rouvre en lecture seule pour vérifier
        self.file.close();
        var read_file = try std.fs.cwd().openFile("reality.scut", .{ .mode = .read_only });

        var found = false;
        var buffer: Hash = undefined;
        
        while (true) {
            const bytes_read = read_file.read(&buffer) catch 0;
            if (bytes_read < 32) break; // Fin du fichier ou hash incomplet

            // Si le hash existe déjà, on sort : l'hologramme est déjà là
            if (std.mem.eql(u8, &buffer, &hash)) {
                found = true;
                break;
            }
            // On avance de la taille du payload (à stocker idéalement en header)
            try read_file.seekBy(@intCast(data.len));
        }
        read_file.close();

        // 2. On ne rouvre en écriture QUE si nécessaire
        self.file = try std.fs.cwd().openFile("reality.scut", .{ .mode = .read_write });

        // Si non trouvé, on écrit à la fin
        if (!found) {
            try self.file.seekFromEnd(0);
            try self.file.writeAll(&hash);
            try self.file.writeAll(data);
        }
    }

    pub fn deinit(self: *ScutStore) void {
        self.file.close();
    }
};
