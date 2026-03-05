const std = @import("std");
const lexer = @import("lexer.zig");
const TokenKind = lexer.TokenKind;
// 1. On importe l'énumération des types
pub const Type = @import("types.zig").Type;

pub const NodeKind = enum {
    program,
    identifier,
    constant,
    unary,
    binary,
    factorial,
    comparison,
    equation,
    forall,
    application,
    domain, 
    set,     
    access,  
    abs,
    negation,
    constant_pi,
    power, // Ajouté pour la suite
};

pub const Node = struct {
    kind: NodeKind,
    data: union {
        string: []const u8,            
        list: []*Node,                 
        unary: *Node,                  
        binary: struct {               
            left: *Node,
            op: TokenKind,
            right: *Node,
        },
        access: struct {       
            array: *Node,      
            index: *Node,      
        },
        forall: struct {               
            vars: []*Node,
            domain: ?*Node,
            body: *Node,
            start: ?*Node = null,
            end: ?*Node = null,
            step: ?*Node = null,
        },
        apply: struct {                
            func: *Node,
            args: []*Node,
        },
    },
    // 2. Le champ de type avec une valeur par défaut
    resolved_type: Type = .invalid, 

    pub fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        switch (self.kind) {
            .program, .set => {
                for (self.data.list) |n| n.deinit(allocator);
                allocator.free(self.data.list);
            },
            // Correction : constant_pi stocke une string ("π" ou "3.14...")
            .identifier, .constant, .domain, .constant_pi => allocator.free(self.data.string),
            
            .unary, .factorial, .abs, .negation => self.data.unary.deinit(allocator),
            
            .binary, .comparison, .equation, .power => {
                self.data.binary.left.deinit(allocator);
                self.data.binary.right.deinit(allocator);
            },
            .access => {
                self.data.access.array.deinit(allocator);
                self.data.access.index.deinit(allocator);  
            },
            .forall => {
                for (self.data.forall.vars) |v| v.deinit(allocator);
                allocator.free(self.data.forall.vars);
                if (self.data.forall.domain) |dom| dom.deinit(allocator);
                if (self.data.forall.start) |n| n.deinit(allocator);
                if (self.data.forall.end) |n| n.deinit(allocator);
                if (self.data.forall.step) |n| n.deinit(allocator);
                self.data.forall.body.deinit(allocator);
            },
            .application => {
                self.data.apply.func.deinit(allocator);
                for (self.data.apply.args) |arg| {
                    arg.deinit(allocator);
                }
                allocator.free(self.data.apply.args); 
            },
        }
        allocator.destroy(self);
    }

    // Helpers de création
    pub fn newConstant(allocator: std.mem.Allocator, val: []const u8) !*Node {
        const node = try allocator.create(Node);
        node.* = .{ 
            .kind = .constant, 
            .data = .{ .string = try allocator.dupe(u8, val) },
            .resolved_type = .integer // Un nombre est souvent un entier par défaut
        };
        return node;
    }

    pub fn newEquation(allocator: std.mem.Allocator, left: *Node, right: *Node) !*Node {
        const node = try allocator.create(Node);
        node.* = .{ 
            .kind = .equation, 
            .data = .{ .binary = .{ .left = left, .op = .assign, .right = right } },
            .resolved_type = .boolean 
        };
        return node;
    }

    pub fn kindToString(self: Node) []const u8 {
        return @tagName(self.kind);
    }
};
