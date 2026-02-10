const std = @import("std");
const Json = std.json;

fn readHeaders(r: anytype) !usize {
    var content_len: usize = 0;
    while (true) {
        var line = try r.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, "\n", 8192);
        if (line == null) break;
        defer std.heap.page_allocator.free(line.?);
        const s = std.mem.trim(u8, line.?, "\r\n");
        if (s.len == 0) break;
        if (std.mem.startsWith(u8, std.ascii.lowerString(std.heap.page_allocator, s) catch s, "content-length:")) {
            const parts = std.mem.splitScalar(u8, s, ":");
            var it = parts; _ = it.next();
            if (it.next()) |val| content_len = std.fmt.parseUnsigned(usize, std.mem.trim(u8, val, " "), 10) catch 0;
        }
    }
    return content_len;
}
fn writeJsonRpc(w: anytype, id: ?Json.Value, method: ?[]const u8, result: ?Json.Value, params: ?Json.Value) !void {
    var obj = Json.ObjectMap.init(std.heap.page_allocator); defer obj.deinit();
    try obj.put("jsonrpc", .{ .String = "2.0" });
    if (id) |v| try obj.put("id", v);
    if (method) |m| try obj.put("method", .{ .String = m });
    if (result) |res| try obj.put("result", res);
    if (params) |p| try obj.put("params", p);
    var root = Json.Value{ .Object = obj };
    var buf = std.ArrayList(u8).init(std.heap.page_allocator); defer buf.deinit();
    try Json.stringify(root, .{}, buf.writer());
    const hdr = std.fmt.allocPrint(std.heap.page_allocator, "Content-Length: {d}\r\n\r\n", .{ buf.items.len }) catch unreachable;
    defer std.heap.page_allocator.free(hdr);
    try w.writeAll(hdr); try w.writeAll(buf.items);
}

fn lineCharOf(s: []const u8, idx: usize) struct {line: usize, ch: usize} {
    var line: usize = 0; var last_nl: usize = 0; var i: usize = 0;
    while (i < idx and i < s.len) : (i += 1) if (s[i] == '\n') { line += 1; last_nl = i+1; }
    return .{ .line = line, .ch = idx - last_nl };
}
fn findSymbolDef(text: []const u8, word: []const u8) ?usize {
    const patterns = [_][]const u8{ "stream ", "actor ", "protocol " };
    for (patterns) |p| {
        var i: usize = 0; while (true) {
            const pos = std.mem.indexOfPos(u8, text, i, p) orelse break;
            const name_start = pos + p.len; var name_end = name_start;
            while (name_end < text.len and std.ascii.isAlphanumeric(text[name_end])) name_end += 1;
            if (std.mem.eql(u8, text[name_start..name_end], word)) return pos;
            i = name_end;
        }
    }
    return null;
}
fn occurrences(text: []const u8, word: []const u8) []usize {
    var arr = std.ArrayList(usize).init(std.heap.page_allocator);
    var i: usize = 0; while (true) {
        const pos = std.mem.indexOfPos(u8, text, i, word) orelse break;
        _ = arr.append(pos) catch {}; i = pos + word.len;
    }
    return arr.toOwnedSlice() catch &[_]usize{};
}

pub fn main() !void {
    var r = std.io.getStdIn().reader(); var w = std.io.getStdOut().writer();
    while (true) {
        const len = try readHeaders(r); if (len == 0) break;
        var buf = try std.heap.page_allocator.alloc(u8, len); defer std.heap.page_allocator.free(buf);
        try r.readNoEof(buf);

        var p = Json.Parser.init(std.heap.page_allocator); defer p.deinit();
        var tree = try p.parse(buf); defer tree.deinit();
        const root = tree.root.Object;
        const id = root.get("id"); const method = root.get("method"); const params = root.get("params");
        if (method == null) continue; const m = method.String;

        if (std.mem.eql(u8, m, "initialize")) {
            var caps = Json.ObjectMap.init(std.heap.page_allocator); defer caps.deinit();
            var td = Json.ObjectMap.init(std.heap.page_allocator); defer td.deinit();
            try td.put("completionProvider", .{ .Object = .{ .entries = &[_]Json.ObjectMap.KV{
                .{ .key = "triggerCharacters", .value = .{ .Array = .{ .items = &[_]Json.Value{
                    .{ .String = ":" }, .{ .String = "," }, .{ .String = "(" } } } } } } } });
            try td.put("documentSymbolProvider", .{ .Boolean = true });
            try td.put("hoverProvider", .{ .Boolean = true });
            try td.put("textDocumentSync", .{ .Integer = 1 });
            try td.put("definitionProvider", .{ .Boolean = true });
            try td.put("renameProvider", .{ .Boolean = true });
            try caps.put("capabilities", .{ .Object = td });
            try writeJsonRpc(w, id.?, null, .{ .Object = caps }, null);

        } else if (std.mem.eql(u8, m, "textDocument/definition")) {
            var word: []const u8 = ""; var text: []const u8 = "";
            if (params) |pv| { const po = pv.Object; if (po.get("word")) |wrd| word = wrd.String; if (po.get("text")) |tx| text = tx.String; }
            const defpos = findSymbolDef(text, word);
            var res = Json.Array.init(std.heap.page_allocator);
            if (defpos) |pos| { const lc = lineCharOf(text, pos); var loc = Json.ObjectMap.init(std.heap.page_allocator);
                _ = loc.put("line", .{ .Integer = @intCast(i64, lc.line) }) catch {};
                _ = loc.put("character", .{ .Integer = @intCast(i64, lc.ch) }) catch {};
                _ = res.append(.{ .Object = loc }) catch {};
            }
            try writeJsonRpc(w, id.?, null, .{ .Array = res }, null);

        } else if (std.mem.eql(u8, m, "textDocument/rename")) {
            var word: []const u8 = ""; var newName: []const u8 = ""; var text: []const u8 = "";
            if (params) |pv| { const po = pv.Object; if (po.get("word")) |wrd| word = wrd.String; if (po.get("newName")) |nn| newName = nn.String; if (po.get("text")) |tx| text = tx.String; }
            const occ = occurrences(text, word);
            var edits = Json.Array.init(std.heap.page_allocator);
            for (occ) |pos| {
                const lc = lineCharOf(text, pos); var e = Json.ObjectMap.init(std.heap.page_allocator);
                var r = Json.ObjectMap.init(std.heap.page_allocator); var s = Json.ObjectMap.init(std.heap.page_allocator); var en = Json.ObjectMap.init(std.heap.page_allocator);
                _ = s.put("line", .{ .Integer = @intCast(i64, lc.line) }) catch {};
                _ = s.put("character", .{ .Integer = @intCast(i64, lc.ch) }) catch {};
                _ = en.put("line", .{ .Integer = @intCast(i64, lc.line) }) catch {};
                _ = en.put("character", .{ .Integer = @intCast(i64, lc.ch + word.len) }) catch {};
                _ = r.put("start", .{ .Object = s }) catch {}; _ = r.put("end", .{ .Object = en }) catch {};
                _ = e.put("range", .{ .Object = r }) catch {}; _ = e.put("newText", .{ .String = newName }) catch {};
                _ = edits.append(.{ .Object = e }) catch {};
            }
            var out = Json.ObjectMap.init(std.heap.page_allocator);
            _ = out.put("documentChanges", .{ .Array = edits }) catch {};
            try writeJsonRpc(w, id.?, null, .{ .Object = out }, null);

        } else {
            var res = Json.ObjectMap.init(std.heap.page_allocator); defer res.deinit();
            try res.put("ok", .{ .Boolean = true });
            try writeJsonRpc(w, id.?, null, .{ .Object = res }, null);
        }
    }
}

