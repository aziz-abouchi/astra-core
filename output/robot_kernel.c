#include <math.h>

// Calcul généré par Astra avec vérification de précision
void update_arm_position() {
    float theta = 0.3398f;
    float sigma = 0.0135f; // Incertitude propagée

    if (sigma > 0.05f) {
        // Arrêt si le capteur est trop imprécis pour garantir la position
        emergency_shutdown_unstable_sensor();
    } else {
        set_servo_radians(0, theta);
    }
}
