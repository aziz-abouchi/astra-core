# Build global
zig build
 
# Produire WASM exécutable (main exporté)
zig-out/bin/astra-wasm lang/examples/pipeline_run.astra
 
# Sidecar P2P
ASTRA_P2P_SOCK=/tmp/astra-p2p.sock ./sidecar/astra-p2p/target/release/astra-p2p
 
# Runner WASM Zig (imports riches → runtime)
ASTRA_P2P_SOCK=/tmp/astra-p2p.sock zig-out/bin/astra-wasmtime-zig out.wasm
 
# Metrics server + Parquet auto
zig-out/bin/astra-metricsd --port 8080 --export-parquet-every 30
curl http://localhost:8080/metrics
 
# Dashboard
python3 -m http.server
# http://localhost:8000/dashboard/
