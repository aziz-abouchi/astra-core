const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn startServer(eg: *EGraph.EGraph) !void {
    const address = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try address.listen(.{ .reuse_address = true });

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();
        serveResponse(conn, eg) catch |err| {
            std.debug.print("Erreur serveur: {}\n", .{err});
        };
    }
}

fn serveResponse(conn: std.net.Server.Connection, eg: *EGraph.EGraph) !void {
    var read_buf: [1024]u8 = undefined;
    _ = conn.stream.read(&read_buf) catch 0;

    const stream = conn.stream;
    try stream.writeAll("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n");

    try stream.writeAll(
        \\<!DOCTYPE html><html><head><meta charset="utf-8">
        \\<script src="https://d3js.org/d3.v7.min.js"></script>
        \\<style>
        \\  body { background: #050505; color: #00ff41; font-family: 'Courier New', monospace; margin: 0; overflow: hidden; }
        \\  .node { fill: #111; stroke: #00ff41; stroke-width: 2px; }
        \\  .eclass { fill: #002200; stroke: #00ff41; stroke-dasharray: 5; opacity: 0.5; }
        \\  .link { stroke: #00ff41; stroke-opacity: 0.3; }
        \\  text { fill: #00ff41; font-size: 11px; font-weight: bold; pointer-events: none; }
        \\  h1 { position: absolute; width: 100%; text-align: center; font-size: 1rem; z-index: 10; text-shadow: 0 0 5px #00ff41; }
        \\</style></head><body><h1>ASTRA // LIVE E-GRAPH EXPLORER</h1><div id="g"></div><script>
    );

    try stream.writeAll("const data = { \"nodes\": [");
    
    var first = true;
    var fmt_buf: [512]u8 = undefined;

    // 1. Export des E-Classes uniques (on utilise le tableau parents)
    // On crée un set d'IDs de racines pour ne pas dupliquer les cercles d'E-Classes
    var eclass_map = std.AutoHashMap(u32, void).init(std.heap.page_allocator);
    defer eclass_map.deinit();

    for (0..eg.len) |i| {
        const root = eg.find(@intCast(i));
        if (eclass_map.get(root) == null) {
            try eclass_map.put(root, {});
            if (!first) try stream.writeAll(",");
            first = false;
            const class_json = try std.fmt.bufPrint(&fmt_buf, "{{\"id\":\"C{d}\",\"type\":\"eclass\",\"label\":\"Class {d}\"}}", .{root, root});
            try stream.writeAll(class_json);
        }
    }

    // 2. Export des E-Nodes
    for (eg.nodes[0..eg.len], 0..) |node, i| {
        try stream.writeAll(",");
        
        var label_final: []const u8 = "";
        var label_scrubbed: [64]u8 = undefined;

        switch (node) {
            .Atomic => |name| {
                // On filtre agressivement : on ne garde que alpha-numériques
                var count: usize = 0;
                for (name) |char| {
                    if (std.ascii.isAlphanumeric(char)) {
                        label_scrubbed[count] = char;
                        count += 1;
                    }
                    if (count >= 63) break;
                }
                label_final = label_scrubbed[0..count];
                if (label_final.len == 0) label_final = "atom";
            },
            .Scalar => |q| {
                label_final = try std.fmt.bufPrint(&label_scrubbed, "{d}", .{q.value});
            },
            .Operation => |op| {
                label_final = @tagName(op.op);
            },
            .Vector => label_final = "Vector",
            .Hole => label_final = "Hole",
        }

        // On utilise {s} pour injecter le label propre
        const node_json = try std.fmt.bufPrint(&fmt_buf, "{{\"id\":\"N{d}\",\"type\":\"node\",\"label\":\"{s}\"}}", .{ i, label_final });
        try stream.writeAll(node_json);
    }

    try stream.writeAll("], \"links\": [");

    // 3. Liens : Chaque Node pointe vers sa Root Class
    var first_link = true;
    for (0..eg.len) |i| {
        const root = eg.find(@intCast(i));
        if (!first_link) try stream.writeAll(",");
        first_link = false;
        
        const link_json = try std.fmt.bufPrint(&fmt_buf, "{{\"source\":\"N{d}\",\"target\":\"C{d}\"}}", .{i, root});
        try stream.writeAll(link_json);
    }

    try stream.writeAll("] };");

    // 4. Script D3.js
    try stream.writeAll(
        \\const w=window.innerWidth, h=window.innerHeight;
        \\const svg=d3.select("#g").append("svg").attr("width",w).attr("height",h);
        \\const sim=d3.forceSimulation(data.nodes)
        \\    .force("link",d3.forceLink(data.links).id(d=>d.id).distance(d=>d.type==="eclass"?100:50))
        \\    .force("charge",d3.forceManyBody().strength(-200))
        \\    .force("center",d3.forceCenter(w/2,h/2));
        \\const link=svg.append("g").selectAll("line").data(data.links).enter().append("line").attr("class","link");
        \\const node=svg.append("g").selectAll("circle").data(data.nodes).enter().append("circle")
        \\    .attr("r",d=>d.type==="eclass"?35:15).attr("class",d=>d.type)
        \\    .call(d3.drag().on("start",dragS).on("drag",dragged).on("end",dragE));
        \\const text=svg.append("g").selectAll("text").data(data.nodes).enter().append("text")
        \\    .text(d=>d.label).attr("text-anchor","middle").attr("dy", ".35em");
        \\sim.on("tick",()=>{
        \\    link.attr("x1",d=>d.source.x).attr("y1",d=>d.source.y).attr("x2",d=>d.target.x).attr("y2",d=>d.target.y);
        \\    node.attr("cx",d=>d.x).attr("cy",d=>d.y);
        \\    text.attr("x",d=>d.x).attr("y",d=>d.y);
        \\});
        \\function dragS(e,d){if(!e.active)sim.alphaTarget(0.3).restart();d.fx=d.x;d.fy=d.y;}
        \\function dragged(e,d){d.fx=e.x;d.fy=e.y;}
        \\function dragE(e,d){if(!e.active)sim.alphaTarget(0);d.fx=null;d.fy=null;}
        \\</script></body></html>
    );
}
