// Code généré par Astra pour un bras robotique
float target_theta = 45.2; 
float uncertainty = 0.05;

if (uncertainty > TOLERANCE_MAX) {
    emergency_stop("Précision physique insuffisante pour le mouvement");
} else {
    move_servo(target_theta);
}

pub fn generateServoControl(eg: *EGraph, target_id: EClassId) !void {
    // Astra calcule les angles et injecte les vérifications de sécurité
    // par rapport à l'incertitude propagée par GUPI.
    const q = eg.getBestQuantity(target_id);
    std.debug.print("⚙️ [Robot]: Génération PulseWidth pour angle {d} ± {d}\n", .{q.toF64(), q.uncertainty});
}
