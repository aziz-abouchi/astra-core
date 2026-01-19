# Sprint — WASM bindings structurés + LSP (definitions/rename) + Metrics par-topic + Dashboard
**Date**: '"$(date +%Y-%m-%d)"' 

## WASM — bindings structurés
- `env.window(size,slide)`, `env.session(timeout)` : configurent le runtime.
- `env.publishTopic(ptr,len)`, `env.publishPayload(ptr,len)`, `env.publishCommit()` : publication native vers le runtime Zig (EventLoop/Streams/GossipSub).
- `env.subscribe(ptr,len)` : abonne EventLoop et enregistre un handler qui compte par topic.

## LSP — complet (MVP avancé)
- `textDocument/definition` : renvoie la position de la définition (stream/actor/protocol).
- `textDocument/rename` : renvoie des workspace edits (remplacements mot‑à‑mot).
- Diagnostics positionnés, complétions contextuelles et outline.

## Metrics — par topic
- Export JSON/CSV `metrics/topics_volume.*` (volumétrie par topic).
- Serveur `/metrics` enrichi : inclut `topics_volume.json` + p50/p95/p99.
- Parquet auto sur `actors_metrics.csv`, `window_metrics_rolling.csv`, `topics_volume.csv`.

## Dashboard
- Top Topics (bar chart) + graphe flush p50/p95/p99 + tableau acteurs + aperçu fenêtres CSV.
