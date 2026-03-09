const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(egraph: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = egraph.nodes[id];

    buf.print("(module\n", .{});
    // On importe deux types de logs depuis l'hôte (JS/Heaven)
    buf.print("  (import \"env\" \"log_f64\" (func $log_f64 (param f64)))\n", .{});
    buf.print("  (import \"env\" \"log_vec3\" (func $log_vec3 (param f64 f64 f64)))\n", .{});
    buf.print("  (func (export \"main\")\n", .{});

    switch (node) {
        .Constant => |val| {
            // Pour 120.0
            buf.print("    f64.const {d}\n", .{val});
            buf.print("    call $log_f64\n", .{});
        },
        .Vector => |v| {
            // Pour vec3(x, y, z)
            buf.print("    f64.const {d}\n", .{v.data[0]});
            buf.print("    f64.const {d}\n", .{v.data[1]});
            buf.print("    f64.const {d}\n", .{v.data[2]});
            buf.print("    call $log_vec3\n", .{});
        },
        else => {
            // Cas par défaut ou opération non résolue
            buf.print("    ;; Noeud complexe non géré en WAT\n", .{});
        },
    }

    buf.print("  )\n)\n", .{});
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    switch (node) {
        .Operation => |op| {
            // Cas : Scalaire * Vecteur
            if (op.op == .Mul and eg.isVector(op.right)) {
                emit(eg, op.left, buf); // Pousse le scalaire (ex: 10)
                buf.print("    local.set $s\n", .{}); 
                
                // On récupère le vecteur (qui est maintenant un vrai .Vector grâce au Lens)
                const v_id = eg.getBestId(op.right);
                const v = eg.nodes[v_id].Vector;
                
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[0]});
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[1]});
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[2]});
            } 
            // Cas : Vecteur * Scalaire (optionnel mais propre)
            else if (op.op == .Mul and eg.isVector(op.left)) {
                emit(eg, op.right, buf);
                buf.print("    local.set $s\n", .{});
                const v = eg.nodes[eg.getBestId(op.left)].Vector;
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[0]});
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[1]});
                buf.print("    f64.const {d} local.get $s f64.mul\n", .{v.data[2]});
            }
            else {
                emit(eg, op.left, buf);
                emit(eg, op.right, buf);
                buf.print("    f64.{s}\n", .{getWatOp(op.op)});
            }
        },
        .Constant => |val| buf.print("    f64.const {d}\n", .{val}),
        .Vector => |v| buf.print("    f64.const {d} f64.const {d} f64.const {d}\n", .{v.data[0], v.data[1], v.data[2]}),
        //.Atomic => |name| buf.print("    ;; atomic {s}\n", .{name}),
        .Atomic => buf.print("    ;; atomic\n", .{}),
    }
}

fn getWatOp(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "add", .Sub => "sub", .Mul => "mul", .Div => "div",
        else => "nop",
    };
}
