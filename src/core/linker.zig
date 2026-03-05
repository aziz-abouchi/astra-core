pub const ResourceType = enum {
    memory_mapped_io, // Pour Forth/Fortran (Adresses)
    actor_proxy,       // Pour Pony/Erlang (Identifiants d'acteurs)
    virtual_symbol,    // Pour LaTeX/Heaven (Documentation)
};

pub const Binding = struct {
    name: []const u8,
    res_type: ResourceType,
    address: ?usize = null, // ex: 0x40021000 pour un capteur
    unit: ?Dimension = null,
};

// Dans le Linker : Orchestration du branchement
pub fn link(ast_node: *ast.Node, target: TargetKind) !void {
    const binding = registry.lookup(ast_node.name);
    
    switch (target) {
        .forth => {
            // Remplace l'accès à la variable par une lecture mémoire
            ast_node.transformed_code = std.fmt.allocPrint("0x{X} @", .{binding.address});
        },
        .pony => {
            // Transforme en appel de comportement (behavior)
            ast_node.transformed_code = "sensor.get_velocity()";
        },
        .latex => {
            // Formate pour une notation académique élégante
            ast_node.transformed_code = "\\vec{v}_{drone}";
        }
    }
}
