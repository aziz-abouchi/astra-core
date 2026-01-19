const Instr = @import("ir.zig").Instr;

pub const VM = struct {
    regs: [256]f64,

    pub fn run(self: *VM, code: []Instr) f64 {
        for (code) |ins| switch (ins) {
            .LoadImm => |i| self.regs[i.dst] = i.value,
            .Add => |i| self.regs[i.dst] = self.regs[i.a] + self.regs[i.b],
            .Mul => |i| self.regs[i.dst] = self.regs[i.a] * self.regs[i.b],
            .Dot => |i| {
                var acc: f64 = 0;
                var k: usize = 0;
                while (k < i.len) : (k += 1) {
                    acc += self.regs[i.v1 + k] * self.regs[i.v2 + k];
                }
                self.regs[i.dst] = acc;
            },
            .Ret => |r| return self.regs[r],
        };
        return 0;
    }
};

