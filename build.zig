const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Définition de l'exécutable principal "surge"
    const exe = b.addExecutable(.{
        .name = "surge",
        .root_module = b.createModule(.{ 
		.root_source_file = b.path("src/main.zig"),
        	.target = target,
        	.optimize = optimize,
	},),
    });

    // Ajout des modules en tant que packages pour une meilleure structure
    const core_mod = b.addModule("core", .{ .root_source_file = b.path("src/core/core.zig") });
    const engines_mod = b.addModule("engines", .{ .root_source_file = b.path("src/engines/unify.zig") });
    const hub_mod = b.addModule("hub", .{ .root_source_file = b.path("src/hub/projector.zig") });

    hub_mod.addImport("core", core_mod);

    exe.root_module.addImport("core", core_mod);
    exe.root_module.addImport("engines", engines_mod);
    exe.root_module.addImport("hub", hub_mod);

    b.installArtifact(exe);

    // --- Étape de Test de Projection ---
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    
    // Commande personnalisée : zig build test-forth
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const test_step = b.step("test-forth", "Exécuter le test de projection Heaven vers Forth");
    run_cmd.addArgs(&.{ "compile", "--target=forth", "tests/hpc/dot_product.hvn" });
    test_step.dependOn(&run_cmd.step);
}
