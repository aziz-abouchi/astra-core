# Build global
zig build
 
# Produire WASM exécutable (main exporté)
zig-out/bin/heaven-wasm lang/examples/pipeline_run.heaven
 
# Sidecar P2P
HEAVEN_P2P_SOCK=/tmp/heaven-p2p.sock ./sidecar/heaven-p2p/target/release/heaven-p2p
 
# Runner WASM Zig (imports riches → runtime)
HEAVEN_P2P_SOCK=/tmp/heaven-p2p.sock zig-out/bin/heaven-wasmtime-zig out.wasm
 
# Metrics server + Parquet auto
zig-out/bin/heaven-metricsd --port 8080 --export-parquet-every 30
curl http://localhost:8080/metrics
 
# Dashboard
python3 -m http.server
# http://localhost:8000/dashboard/
