// runtime/actor.zig
const std = @import("std");
const VM = @import("vm.zig").VM;
const bytecode = @import("bytecode.zig");
const ast = @import("ast.zig");

pub const Actor = struct {
    id: []const u8,
    port: u16,
    peers: []const u16,
    vm: VM,

    pub fn init(id: []const u8, port: u16, peers: []const u16) Actor {
        return Actor{
            .id = id,
            .port = port,
            .peers = peers,
            .vm = VM.init(),
        };
    }

    pub fn run(self: *Actor) !void {
        var gpa = try std.net.StreamServer.listen(.{}, std.net.Address.parseIp4("0.0.0.0", self.port));
        defer gpa.close();

        const stdout = std.io.getStdOut().writer();

        while (true) {
            try stdout.print("Actor {s} waiting...\n", .{self.id});
            try stdout.flush();

            // Accepte un client TCP
            var conn = try gpa.accept();
            defer conn.close();

            // Lire un vecteur envoyé
            var buf: [256]u8 = undefined;
            const n = try conn.reader().read(&buf);
            const vec_str = buf[0..n];
            // Parser minimal en float vector
            var vec: [4]f32 = undefined;
            for (0..4) |i| vec[i] = 1.0; // placeholder pour parser

            self.vm.stack[0] = ast.Expr.Vec(vec[0..]);
            self.vm.sp = 1;

            // Simuler dot product avec le vecteur local
            var instrs: [1]bytecode.Instr = .{ bytecode.Instr.Dot{} };
            try self.vm.execute(instrs[0..]);

            try stdout.print("Actor {s} computed dot product result\n", .{self.id});
        }
    }
};
