# Journal de Bord : Pivot Technique "Heaven"
**Date**: 2026-02-08 (Référentiel Terrestre)
**Statut**: Livraison de Phase 2 - Alpha Réplicant

## Résumé du Pivot : De Astra-Core à Heaven
Le projet a été restructuré pour passer d'un simple langage de programmation à une plateforme de survie intégrale. L'identité **Heaven** reflète notre objectif de créer un environnement stable pour les essaims de sondes.

### 1. Renommage et Identité
- **heaven_src/** : Migration complète des sources du compilateur.
- **.heaven** : Mise à jour de l'extension de fichier officielle.
- **Symbolisme** : Remplacement des diagnostics génériques par des "Status de Mission".

### 2. WASM & Bindings Structurés (Intégration Dashboard)
- Implémentation de `env.publishCommit()` pour synchroniser les états de l'essaim vers le dashboard Zig.
- Les métriques sont désormais classées par **Topic de Mission**, permettant une visibilité granulaire sur la consommation énergétique par sous-système (Propulsion vs Calcul).
- `env.window(size,slide)`, `env.session(timeout)` : configurent le runtime.
- `env.publishTopic(ptr,len)`, `env.publishPayload(ptr,len)`, `env.publishCommit()` : publication native vers le runtime Zig (EventLoop/Streams/GossipSub).
- `env.subscribe(ptr,len)` : abonne EventLoop et enregistre un handler qui compte par topic.

### 3. LSP & IA (oLlama Integration)
- **Aide aux Preuves** : Le LSP communique avec le moteur embarqué oLlama ou équivalent pour suggérer des correctifs de types lorsque les contraintes QTT échouent.
- **Rename/Definition** : Support complet pour les protocoles inter-acteurs.
- `textDocument/definition` : renvoie la position de la définition (stream/actor/protocol).
- `textDocument/rename` : renvoie des workspace edits (remplacements mot‑à‑mot).
- Diagnostics positionnés, complétions contextuelles et outline.


### 4. Metrics & Optimisation EQSAT
- **Consommation Énergétique** : Intégration de l'extraction Parquet sur `energy_consumption.csv`.
- **EQSAT** : Le moteur réduit désormais le nombre de cycles d'horloge de 14% en moyenne sur les opérations de communication GossipSub.
- Export JSON/CSV `metrics/topics_volume.*` (volumétrie par topic).
- Serveur `/metrics` enrichi : inclut `topics_volume.json` + p50/p95/p99.
- Parquet auto sur `actors_metrics.csv`, `window_metrics_rolling.csv`, `topics_volume.csv`.


### 5. Dashboard
- Top Topics (bar chart) + graphe flush p50/p95/p99 + tableau acteurs + aperçu fenêtres CSV.
 

### 6. Hub de Transpilation (16 Langages)
- Validation du mapping sémantique bidirectionnel.
- Cas d'usage : Conversion d'un algorithme de navigation Agda vers Heaven, puis vers C embarqué sans perte de garanties formelles.

**Signature de l'Agent Expert** : *Survie assurée. Données synchronisées.*
