const std = @import("std");
const c = @cImport({ @cInclude("wasmtime.h"); });
const Host = @import("../../src/runtime_host.zig");

fn readGuestBytes(store: *c.wasmtime_store_t, memory: *c.wasmtime_memory_t,
                  ptr: u32, len: u32, allocator: std.mem.Allocator) ![]u8 {
    var data_ptr: ?[*]u8 = null; var data_len: usize = 0;
    c.wasmtime_memory_data(store, memory, &data_ptr, &data_len);
    if (data_ptr == null or data_len == 0) return error.MemUnavailable;
    if (@intCast(usize, ptr) + @intCast(usize, len) > data_len) return error.MemOutOfRange;
    const src = data_ptr.?[@intCast(usize, ptr)..@intCast(usize, ptr + len)];
    var out = try allocator.alloc(u8, src.len); std.mem.copy(u8, out, src); return out;
}

const State = struct {
    allocator: std.mem.Allocator,
    store: *c.wasmtime_store_t,
    memory: c.wasmtime_memory_t,
    pending_topic: []u8 = &[_]u8{},
    pending_payload: []u8 = &[_]u8{},
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; defer std.debug.assert(!gpa.deinit());
    const a = gpa.allocator();
    var args = try std.process.argsAlloc(a); defer std.process.argsFree(a, args);
    const wasm_path = if (args.len > 1) args[1] else "out.wasm";
    const sock_path = std.os.getenvZ("HEAVEN_P2P_SOCK") orelse "/tmp/heaven-p2p.sock";
    try Host.setupRuntime(sock_path);

    var engine: *c.wasmtime_engine_t = c.wasmtime_engine_new(); defer c.wasmtime_engine_delete(engine);
    var store: *c.wasmtime_store_t = c.wasmtime_store_new(engine, null, null); defer c.wasmtime_store_delete(store);
    var linker: *c.wasmtime_linker_t = c.wasmtime_linker_new(engine); defer c.wasmtime_linker_delete(linker);

    const host_window = struct {
        pub fn tramp(_: *anyopaque, _: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            if (nargs >= 2 and args[0].kind == c.WASMTIME_I64 and args[1].kind == c.WASMTIME_I64)
                Host.setWindow(@bitCast(u64, args[0].of.i64), @bitCast(u64, args[1].of.i64));
            return null;
        }
    };
    const host_session = struct {
        pub fn tramp(_: *anyopaque, _: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            if (nargs >= 1 and args[0].kind == c.WASMTIME_I64) Host.setSession(@bitCast(u64, args[0].of.i64));
            return null;
        }
    };
    const host_log = struct {
        pub fn tramp(_: *anyopaque, _: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            if (nargs >= 1 and args[0].kind == c.WASMTIME_I32) std.log.info("[env.log] {d}", .{ args[0].of.i32 });
            return null;
        }
    };

    var state = State{ .allocator = a, .store = store, .memory = undefined };

    const host_pub_topic = struct {
        pub fn tramp(arg: *anyopaque, caller: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            var s = @ptrCast(*State, arg);
            var ext = c.wasmtime_extern_t{ .kind = c.WASMTIME_EXTERN_NULL, .of = undefined };
            _ = c.wasmtime_caller_export_get(caller, "memory", 6, &ext);
            if (ext.kind == c.WASMTIME_EXTERN_MEMORY) s.memory = ext.of.memory;
            if (nargs >= 2 and args[0].kind == c.WASMTIME_I32 and args[1].kind == c.WASMTIME_I32) {
                const ptr = @as(u32, @bitCast(args[0].of.i32)); const len = @as(u32, @bitCast(args[1].of.i32));
                if (s.pending_topic.len > 0) s.allocator.free(s.pending_topic);
                s.pending_topic = readGuestBytes(s.store, &s.memory, ptr, len, s.allocator) catch &[_]u8{};
            }
            return null;
        }
    };
    const host_pub_payload = struct {
        pub fn tramp(arg: *anyopaque, caller: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            var s = @ptrCast(*State, arg);
            var ext = c.wasmtime_extern_t{ .kind = c.WASMTIME_EXTERN_NULL, .of = undefined };
            _ = c.wasmtime_caller_export_get(caller, "memory", 6, &ext);
            if (ext.kind == c.WASMTIME_EXTERN_MEMORY) s.memory = ext.of.memory;
            if (nargs >= 2 and args[0].kind == c.WASMTIME_I32 and args[1].kind == c.WASMTIME_I32) {
                const ptr = @as(u32, @bitCast(args[0].of.i32)); const len = @as(u32, @bitCast(args[1].of.i32));
                if (s.pending_payload.len > 0) s.allocator.free(s.pending_payload);
                s.pending_payload = readGuestBytes(s.store, &s.memory, ptr, len, s.allocator) catch &[_]u8{};
            }
            return null;
        }
    };
    const host_pub_commit = struct {
        pub fn tramp(arg: *anyopaque, _: *c.wasmtime_caller_t, _: [*]c.wasmtime_val_t, _: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            var s = @ptrCast(*State, arg);
            if (s.pending_topic.len > 0 and s.pending_payload.len > 0) {
                _ = Host.publishNative(s.pending_topic, s.pending_payload) catch {};
            }
            return null;
        }
    };
    const host_sub = struct {
        pub fn tramp(arg: *anyopaque, caller: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            var s = @ptrCast(*State, arg);
            var ext = c.wasmtime_extern_t{ .kind = c.WASMTIME_EXTERN_NULL, .of = undefined };
            _ = c.wasmtime_caller_export_get(caller, "memory", 6, &ext);
            if (ext.kind == c.WASMTIME_EXTERN_MEMORY) s.memory = ext.of.memory;
            if (nargs >= 2 and args[0].kind == c.WASMTIME_I32 and args[1].kind == c.WASMTIME_I32) {
                const ptr = @as(u32, @bitCast(args[0].of.i32)); const len = @as(u32, @bitCast(args[1].of.i32));
                const topic = readGuestBytes(s.store, &s.memory, ptr, len, s.allocator) catch return null;
                defer s.allocator.free(topic);
                _ = Host.subscribeNative(topic, 5) catch {};
            }
            return null;
        }
    };
    const host_flush = struct {
        pub fn tramp(_: *anyopaque, _: *c.wasmtime_caller_t, args: [*]c.wasmtime_val_t, nargs: usize,
                     _: [*]c.wasmtime_val_t, _: usize) callconv(.C) c.wasmtime_trap_t {
            if (nargs >= 2 and args[0].kind == c.WASMTIME_I64 and args[1].kind == c.WASMTIME_I64)
                _ = Host.flushNative(@bitCast(u64, args[0].of.i64), @bitCast(u64, args[1].of.i64)) catch {};
            return null;
        }
    };

    var ftype: *c.wasmtime_functype_t = undefined; var func: c.wasmtime_func_t = undefined;

    ftype = c.wasmtime_functype_new2(c.wasmtime_valtype_new_i64(), c.wasmtime_valtype_new_i64(), null);
    c.wasmtime_func_new(linker, store, ftype, host_window.tramp, null, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "window", 6, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new(c.wasmtime_valtype_new_i64(), null);
    c.wasmtime_func_new(linker, store, ftype, host_session.tramp, null, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "session", 7, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new(c.wasmtime_valtype_new_i32(), null);
    c.wasmtime_func_new(linker, store, ftype, host_log.tramp, null, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "log", 3, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new2(c.wasmtime_valtype_new_i32(), c.wasmtime_valtype_new_i32(), null);
    c.wasmtime_func_new(linker, store, ftype, host_pub_topic.tramp, &state, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "publishTopic", 12, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new2(c.wasmtime_valtype_new_i32(), c.wasmtime_valtype_new_i32(), null);
    c.wasmtime_func_new(linker, store, ftype, host_pub_payload.tramp, &state, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "publishPayload", 14, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new(null, null);
    c.wasmtime_func_new(linker, store, ftype, host_pub_commit.tramp, &state, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "publishCommit", 13, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new2(c.wasmtime_valtype_new_i32(), c.wasmtime_valtype_new_i32(), null);
    c.wasmtime_func_new(linker, store, ftype, host_sub.tramp, &state, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "subscribe", 9, c.wasmtime_func_as_extern(&func));

    ftype = c.wasmtime_functype_new2(c.wasmtime_valtype_new_i64(), c.wasmtime_valtype_new_i64(), null);
    c.wasmtime_func_new(linker, store, ftype, host_flush.tramp, null, null, &func);
    _ = c.wasmtime_linker_define(linker, "env", 3, "flush", 5, c.wasmtime_func_as_extern(&func));

    var wasm_bytes = try std.fs.cwd().readFileAlloc(a, wasm_path, 50_000_000); defer a.free(wasm_bytes);
    var module: *c.wasmtime_module_t = null;
    if (c.wasmtime_module_new(engine, wasm_bytes.ptr, wasm_bytes.len, &module) != 0) return error.ModuleCreateFailed;
    defer c.wasmtime_module_delete(module);

    var instance: c.wasmtime_instance_t = undefined; var trap: *c.wasmtime_trap_t = null;
    if (c.wasmtime_linker_instantiate(linker, store, module, &instance, &trap) != 0) return error.InstantiateFailed;

    var name = c.wasmtime_name_t{ .data = "main", .size = 4 };
    var item = c.wasmtime_extern_t{ .kind = c.WASMTIME_EXTERN_NULL, .of = undefined };
    if (c.wasmtime_instance_export_get(store, &instance, name.data, name.size, &item)) |ok|
        if (ok == 0 and item.kind == c.WASMTIME_EXTERN_FUNC) {
            var f = item.of.func; _ = c.wasmtime_func_call(store, &f, null, 0, null, 0, &trap);
        }
}

