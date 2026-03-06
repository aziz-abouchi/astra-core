// surge_core/scut_store/storage.zig

const Hash = [32]u8; // Blake3 identity

pub const ScutEntry = struct {
    hash: Hash,
    node_type: u8,
    data_len: u32,
    // Les dépendances forment le graphe (Merkle-DAG)
    dependencies: []const Hash, 
    payload: []const u8,
};

pub const ScutStore = struct {
    db_file: std.fs.File,
    index: std.AutoHashMap(Hash, u64), // Hash -> Offset disque

    pub fn put(self: *ScutStore, entry: ScutEntry) !void {
        // 1. Vérifier si le Hash existe déjà (Holographie)
        if (self.index.contains(entry.hash)) return;

        // 2. Écrire à la fin du fichier (Append-only pour la vitesse)
        const offset = try self.db_file.getEndPos();
        try self.writeEntry(entry);

        // 3. Mettre à jour l'index en mémoire
        try self.index.put(entry.hash, offset);
    }
};
