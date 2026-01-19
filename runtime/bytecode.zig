const std = @import("std");
const Expr = @import("ast.zig").Expr;

pub const Instr = union(enum) {
    LoadInt: i64,
    Dot,
    Choice: u8,
    Now,
    Rand,
    Halt,
    PushInt: i32,
    PushVec: []f32,
    Send: struct { to: []const u8 },
    Recv: struct { from: []const u8 },
    LoopStart: i32,
    LoopEnd: void,
    ChoiceStart: i32,
    ChoiceEnd: void,
    Dot: void, // SIMD dot product

};

pub fn compile(exprs: []Expr) ![]Instr {
    var buf: [256]Instr = undefined;
    var i: usize = 0;

    for (exprs) |e| {
        switch (e) {
            Expr.Int => |v| buf[i] = Instr.PushInt(v),
            Expr.Vec => |vec| buf[i] = Instr.PushVec(vec),
            Expr.Send => |s| buf[i] = Instr.Send(.{ .to = s.to }),
            Expr.Recv => |r| buf[i] = Instr.Recv(.{ .from = r.from }),
            Expr.Loop => |l| {
                buf[i] = Instr.LoopStart(l.count);
                // for simplicity, recursive compile omitted
                buf[i+1] = Instr.LoopEnd{};
            },
            Expr.Choice => |c| {
                buf[i] = Instr.ChoiceStart(c.branches.len);
                buf[i+1] = Instr.ChoiceEnd{};
            },
        }
        i += 1;
    }
    return buf[0..i];
}
