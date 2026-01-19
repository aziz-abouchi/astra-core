
const std = @import("std");

pub const ValueId = usize;
pub const BlockId = usize;

pub const Type = enum { I64, Bool, PtrI64 };

pub const Instr = union(enum) {
  Alloca: struct { ty: Type, name: []const u8 },
  Store:  struct { src: ValueId, dst: ValueId },
  Load:   struct { dst_ty: Type, ptr: ValueId },
  Mul:    struct { lhs: ValueId, rhs: ValueId },
  Sub:    struct { lhs: ValueId, rhs: ValueId },
  IcmpEq: struct { lhs: ValueId, rhs: ValueId },
  Phi:    struct { ty: Type, incoming0: ValueId, incoming1: ValueId },
  Br:     struct { cond: ?ValueId, then_blk: BlockId, else_blk: ?BlockId },
  Ret:    struct { val: ValueId },
};

pub const Block = struct {
  id: BlockId,
  name: []const u8,
  instrs: []Instr,
};

pub const Function = struct {
  name: []const u8,
  args: []const Type,
  ret: Type,
  blocks: []Block,
};

pub fn printType(w: anytype, ty: Type) !void {
  switch (ty) {
    .I64 => try w.print("i64", .{}),
    .Bool => try w.print("i1", .{}),
    .PtrI64 => try w.print("i64*", .{}),
  }
}

pub fn printInstr(w: anytype, id: ValueId, instr: Instr) !void {
    switch (instr) {
        .Alloca => |a| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = alloca ");  try printType(w, a.ty);
            try w.writeAll(" ; ");     try w.writeAll(a.name);
            try w.writeAll("\n");
        },
        .Store => |s| {
            try w.writeAll("store i64 %v");   try writeInt(w, s.src);
            try w.writeAll(", i64* %v");      try writeInt(w, s.dst);
            try w.writeAll("\n");
        },
        .Load => |l| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = load ");    try printType(w, l.dst_ty);
            try w.writeAll(", i64* %v");   try writeInt(w, l.ptr);
            try w.writeAll("\n");
        },
        .Mul => |m| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = mul i64 %v");  try writeInt(w, m.lhs);
            try w.writeAll(", %v");         try writeInt(w, m.rhs);
            try w.writeAll("\n");
        },
        .Sub => |s2| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = sub i64 %v");  try writeInt(w, s2.lhs);
            try w.writeAll(", %v");         try writeInt(w, s2.rhs);
            try w.writeAll("\n");
        },
        .IcmpEq => |c| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = icmp eq i64 %v"); try writeInt(w, c.lhs);
            try w.writeAll(", %v");         try writeInt(w, c.rhs);
            try w.writeAll("\n");
        },
        .Phi => |p| {
            try w.writeAll("%v");      try writeInt(w, id);
            try w.writeAll(" = phi ");    try printType(w, p.ty);
            try w.writeAll(" [ %v");      try writeInt(w, p.incoming0);
            try w.writeAll(", %entry ], [ %v"); try writeInt(w, p.incoming1);
            try w.writeAll(", %loop ]\n");
        },
        .Br => |b| {
            if (b.cond) |cond| {
                try w.writeAll("br i1 %v");   try writeInt(w, cond);
                try w.writeAll(", label %b"); try writeInt(w, b.then_blk);
                try w.writeAll(", label %b"); try writeInt(w, b.else_blk.?);
                try w.writeAll("\n");
            } else {
                try w.writeAll("br label %b"); try writeInt(w, b.then_blk);
                try w.writeAll("\n");
            }
        },
        .Ret => |r| {
            try w.writeAll("ret i64 %v");     try writeInt(w, r.val);
            try w.writeAll("\n");
        },
    }
}


pub fn printBlock(w: anytype, blk: Block) !void {
    try w.writeAll("%b");         try writeInt(w, blk.id);
    try w.writeAll(": ; ");       try w.writeAll(blk.name);
    try w.writeAll("\n");
    var id: ValueId = 0;
    for (blk.instrs) |instr| {
        try printInstr(w, id, instr);
        id += 1;
    }
}

pub fn printFunction(w: anytype, f: Function) !void {
    try w.writeAll("function ");  try w.writeAll(f.name);
    try w.writeAll("(");
    for (f.args, 0..) |a, i| {
        if (i > 0) try w.writeAll(", ");
        try printType(w, a);
    }
    try w.writeAll(") -> ");
    try printType(w, f.ret);
    try w.writeAll("\n");
    for (f.blocks) |b| {
        try printBlock(w, b);
    }
}

fn writeInt(w: anytype, x: usize) !void {
    var buf: [32]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "{}", .{x});
    try w.writeAll(s);
}

// Build factorial_tail IR (entry, loop, body, exit) — ids simplifiés
pub fn build_factorial_tail_ir(alloc: std.mem.Allocator) Function {
  // entry
  var entry_instrs = alloc.alloc(Instr, 3) catch @panic("OOM");
  entry_instrs[0] = .{ .Alloca = .{ .ty = .I64, .name = "acc" } };
  entry_instrs[1] = .{ .Store  = .{ .src = 0, .dst = 0 } };
  entry_instrs[2] = .{ .Br     = .{ .cond = null, .then_blk = 1, .else_blk = null } };
  const entry_block = Block{ .id = 0, .name = "entry", .instrs = entry_instrs };

  // loop
  var loop_instrs = alloc.alloc(Instr, 4) catch @panic("OOM");
  loop_instrs[0] = .{ .Phi    = .{ .ty = .I64, .incoming0 = 100, .incoming1 = 102 } };
  loop_instrs[1] = .{ .Load   = .{ .dst_ty = .I64, .ptr = 0 } };
  loop_instrs[2] = .{ .IcmpEq = .{ .lhs = 101, .rhs = 1 } };
  loop_instrs[3] = .{ .Br     = .{ .cond = 102, .then_blk = 3, .else_blk = 2 } };
  const loop_block = Block{ .id = 1, .name = "loop", .instrs = loop_instrs };

  // body
  var body_instrs = alloc.alloc(Instr, 4) catch @panic("OOM");
  body_instrs[0] = .{ .Mul   = .{ .lhs = 101, .rhs = 101 } };
  body_instrs[1] = .{ .Store = .{ .src = 103, .dst = 0 } };
  body_instrs[2] = .{ .Sub   = .{ .lhs = 101, .rhs = 1 } };
  body_instrs[3] = .{ .Br    = .{ .cond = null, .then_blk = 1, .else_blk = null } };
  const body_block = Block{ .id = 2, .name = "body", .instrs = body_instrs };

  // exit
  var exit_instrs = alloc.alloc(Instr, 2) catch @panic("OOM");
  exit_instrs[0] = .{ .Load = .{ .dst_ty = .I64, .ptr = 0 } };
  exit_instrs[1] = .{ .Ret  = .{ .val = 104 } };
  const exit_block = Block{ .id = 3, .name = "exit", .instrs = exit_instrs };

  // blocks
  var blocks = alloc.alloc(Block, 4) catch @panic("OOM");
  blocks[0] = entry_block;
  blocks[1] = loop_block;
  blocks[2] = body_block;
  blocks[3] = exit_block;

  return Function{
    .name = "factorial_tail",
    .args = &[_]Type{ .I64 },
    .ret = .I64,
    .blocks = blocks,
  };
}
