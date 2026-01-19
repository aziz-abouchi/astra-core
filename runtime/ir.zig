pub const Reg = u16;

pub const Instr = union(enum) {
    LoadImm: struct { dst: Reg, value: f64 },
    Add: struct { dst: Reg, a: Reg, b: Reg },
    Mul: struct { dst: Reg, a: Reg, b: Reg },
    Dot: struct { dst: Reg, v1: Reg, v2: Reg, len: usize },
    Ret: Reg,
};
