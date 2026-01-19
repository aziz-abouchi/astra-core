const std = @import("std");

fn readFileAlloc(path: []const u8, a: std.mem.Allocator) []u8 {
    const file = std.fs.cwd().openFile(path, .{ .mode = .read_only }) catch return "".dup(a) catch return &[_]u8{};
    defer file.close();
    return file.readToEndAlloc(a, 10_000_000) catch &[_]u8{};
}
fn percentile_u64(arr: []u64, p: f64) u64 {
    if (arr.len == 0) return 0;
    std.sort.sort(u64, arr, {}, comptime std.sort.asc(u64));
    const idx: usize = @intFromFloat(std.math.floor(p * @as(f64, @floatFromInt(arr.len - 1))));
    return arr[idx];
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; defer std.debug.assert(gpa.deinit() == .ok); const a = gpa.allocator();
    const args = try std.process.argsAlloc(a); defer std.process.argsFree(a, args);
    var port: u16 = 8080; var export_every_s: u32 = 0;
    var i: usize = 1; while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--port") and i+1 < args.len) { port = try std.fmt.parseUnsigned(u16, args[i+1], 10); i+=1; }
        else if (std.mem.eql(u8, args[i], "--export-parquet-every") and i+1 < args.len) { export_every_s = try std.fmt.parseUnsigned(u32, args[i+1], 10); i+=1; }
    }

    if (export_every_s > 0) {
        _ = std.Thread.spawn(.{}, struct { fn run() void {
            while (true) {
                std.time.sleep(@as(u64, export_every_s) * 1_000_000_000);
                const pairs = [_][2][]const u8{
                    .{ "metrics/window_metrics_rolling.csv", "metrics/window_metrics_rolling.parquet" },
                    .{ "metrics/actors_metrics.csv", "metrics/actors_metrics.parquet" },
                    .{ "metrics/topics_volume.csv", "metrics/topics_volume.parquet" },
                };
                for (pairs) |p| {
                    var child = std.process.Child.init(&[_][]const u8{ "python3", "scripts/csv_to_parquet.py", p[0], p[1] }, a);
                    _ = child.spawnAndWait() catch {};
                }
            }
        } }.run, .{}) catch {};
    }

    var server = std.http.Server.init(.{}); defer server.deinit();
    try server.listen(.{ .port = port });
    std.log.info("metrics server listening on :{d}", .{port});

    while (true) {
        var req = try server.accept(a, .{ .static = .{ .max_header_size = 8*1024, .max_method_size = 16, .max_uri_size = 1024 } });
        defer req.deinit();
        const path = req.head.uri.path;
        if (std.mem.eql(u8, path, "/metrics")) {
            const ajson = readFileAlloc("metrics/actors_metrics.json", a);
            const fjson = readFileAlloc("metrics/flush_metrics.json", a);
            const wcsv  = readFileAlloc("metrics/window_metrics_rolling.csv", a);
            const topics = readFileAlloc("metrics/topics_volume.json", a);

            var dts = std.ArrayList(u64).init(a); defer dts.deinit();
            var lines_it = std.mem.splitScalar(u8, wcsv, '\n'); var first = true;
            while (lines_it.next()) |line| {
                if (first) { first=false; continue; }
                if (line.len==0) continue;
                var cols_it = std.mem.splitScalar(u8, line, ','); var col_idx: usize = 0; var dt: u64 = 0;
                while (cols_it.next()) |c| { if (col_idx==4) dt = std.fmt.parseUnsigned(u64, std.mem.trim(u8,c," \r"),10) catch 0; col_idx += 1; }
                _ = dts.append(dt) catch {};
            }
            const p50 = percentile_u64(dts.items, 0.50);
            const p95 = percentile_u64(dts.items, 0.95);
            const p99 = percentile_u64(dts.items, 0.99);

            var res = std.ArrayList(u8).init(a); defer res.deinit();
            try res.writer().print("{\n  \"actors\": {s},\n  \"flush\": {s},\n  \"topics\": {s},\n  \"windows_dt_ns\": { \"p50\": {}, \"p95\": {}, \"p99\": {} }\n}",
                .{ if (ajson.len>0) ajson else "{}", if (fjson.len>0) fjson else "{}", if (topics.len>0) topics else "{}", p50, p95, p99 });
            try req.respond(.{ .status = .ok, .headers = &[_]std.http.Header{ .{ .name = "content-type", .value = "application/json" } }, .body = res.items });
        } else {
            try req.respond(.{ .status = .not_found, .body = "not found" });
        }
    }
}
