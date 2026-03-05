
pub const LatexTarget = struct {
    // ... init, asTarget ...

    fn emitNode(self: *LatexTarget, node: *ast.Node, out: *std.ArrayList(u8)) !void {
        switch (node.kind) {
            .forall => { // Pour ∀
                try out.appendSlice("\\forall ");
                try self.emitNode(node.data.forall.variable, out);
                try out.appendSlice(" \\in ");
                try self.emitNode(node.data.forall.domain, out);
                try out.appendSlice(" : ");
                try self.emitNode(node.data.forall.body, out);
            },
            .factorial => {
                try self.emitNode(node.data.unary, out);
                try out.appendSlice("!");
            },
            .comparison => {
                try self.emitNode(node.data.binary.left, out);
                const sym = if (node.data.binary.op == .geq) "\\geq " else "> ";
                try out.appendSlice(sym);
                try self.emitNode(node.data.binary.right, out);
            },
            .domain => { // Pour ℕ*
                if (std.mem.eql(u8, node.data.string, "ℕ*")) {
                    try out.appendSlice("\\mathbb{N}^*");
                }
            },
            .sum => {
                const s = node.data.sum;
                try out.appendSlice("\\sum_{");
                try self.emitNode(s.variable, out);
                try out.appendSlice("=");
                try self.emitNode(s.start, out);
                try out.appendSlice("}^{");
                try self.emitNode(s.end, out);
                try out.appendSlice("} ");
                try self.emitNode(s.body, out);
            },
            .power => {
                try self.emitNode(node.data.base, out);
                try out.appendSlice("^{");
                try self.emitNode(node.data.exponent, out);
                try out.appendSlice("}");
            },
            else => try out.appendSlice(node.data.string),
        }
    }
};
