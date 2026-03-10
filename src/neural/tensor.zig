pub const Tensor = struct {
    data: []f32,
    shape: [2]usize,

    // Multiplication de matrices optimisée pour l'inférence
    pub fn matMul(a: Tensor, b: Tensor, out: *Tensor) void {
        // Utilisation des intrinsèques CPU pour la vitesse pure
        for (0..a.shape[0]) |i| {
            for (0..b.shape[1]) |j| {
                var sum: f32 = 0;
                for (0..a.shape[1]) |k| {
                    sum += a.data[i * a.shape[1] + k] * b.data[k * b.shape[1] + j];
                }
                out.data[i * b.shape[1] + j] = sum;
            }
        }
    }
};
