// --- Astra Rust Runtime ---
type Vec3 = [f64; 3];

fn vadd(u: Vec3, v: Vec3) -> Vec3 { [u[0]+v[0], u[1]+v[1], u[2]+v[2]] }
fn fdot(u: Vec3, v: Vec3) -> f64 { u[0]*v[0] + u[1]*v[1] + u[2]*v[2] }
fn fcross(u: Vec3, v: Vec3) -> Vec3 {
    [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]
}

fn main() {
    let result = vadd((1, (2) * [1,0,0]));
    println!("{:?}", result);
}

