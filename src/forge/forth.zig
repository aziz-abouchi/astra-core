const std = @import("std");
const EGraph = @import("../saturation/egraph.zig").EGraph;
const EClassId = @import("../saturation/egraph.zig").EClassId;
const FixedBuffer = @import("../main.zig").FixedBuffer;

pub fn emitFull(egraph: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = egraph.nodes[id];

    switch (node) {
        .Constant => |val| {
            // Un simple '.' en Forth affiche le nombre au sommet de la pile
            buf.print("{d} . cr\n", .{val}); 
        },
        .Vector => |v| {
            for (v.data) |val| buf.print("{d} ", .{val});
            buf.print("print-vec{d}\n", .{v.data.len}); // Optionnel: adapter le nom de la fonction
        },
        else => {
            // ... reste du code pour les opérations ...
        },
    }
    buf.print("bye\n", .{}); // Pour quitter Gforth proprement
}

pub fn emit(eg: *EGraph, id: EClassId, buf: *FixedBuffer) void {
    const node = eg.nodes[id];
    
    // Détection des types pour la pile
    var right_is_vec = false;
    if (node == .Operation) {
        right_is_vec = eg.isVector(node.Operation.right);
    }

    switch (node) {
        .Operation => |op| {
            // Ordre Postfixe : Gauche, puis Droite, puis Opérateur
            emit(eg, op.left, buf);
            buf.print(" ", .{});
            emit(eg, op.right, buf);
            buf.print(" ", .{});
            
            if (op.op == .Mul) {
                if (right_is_vec) {
                    buf.print("smul", .{}); // Scalaire * Vecteur
                } else {
                    buf.print("*", .{});    // Scalaire * Scalaire
                }
            } else if (op.op == .Add) {
                buf.print("vadd", .{});
            } else {
                buf.print("{s}", .{getSymbol(op.op)});
            }
        },
        .Atomic => |name| {
            const trimmed = std.mem.trim(u8, &name, " ");
            if (std.mem.startsWith(u8, trimmed, "vec3(")) {
                const start = std.mem.indexOf(u8, trimmed, "(").?;
                const end = std.mem.lastIndexOf(u8, trimmed, ")").?;
                // On remplace les virgules par des espaces pour la pile Forth
                var it = std.mem.tokenizeAny(u8, trimmed[start+1..end], ", ");
                while (it.next()) |num| {
                    buf.print("{s} ", .{num});
                }
            } else {
                buf.print("{s}", .{trimmed});
            }
        },
        .Constant => |val| {
            buf.print("{d} .\n", .{val}); // '.' en Forth imprime le sommet de pile (scalaire)
        },
        .Vector => |v| {
            buf.print("{d} {d} {d} print-vec3\n", .{ v.data[0], v.data[1], v.data[2] });
        },
    }
}

fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+", .Sub => "-", .Mul => "*", .Div => "/",
        .Dot => "fdot", .Cross => "fcross",
    };
}
