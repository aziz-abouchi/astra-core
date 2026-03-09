// Fonctions utilitaires existantes
export const smul = (s, v) => v.map(x => s * x);
export const vadd = (u, v) => u.map((x, i) => x + v[i]);
export const fdot = (u, v) => u.reduce((acc, x, i) => acc + x * v[i], 0);

// L'objet crucial pour WebAssembly
export const wasmEnv = {
    env: {
        log_f64: (val) => console.log(val),
        log_vec3: (x, y, z) => console.log(`[${x}, ${y}, ${z}]`),
        // Ajoute ici d'autres fonctions si ton WAT en demande (ex: sin, cos)
    }
};
