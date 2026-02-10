# Heaven Language Specification (v0.1)

## Objectifs
- Langage concurrent et distribué, inspiré d’Erlang, Pony, Idris2, Prolog, Carp, Goblins.
- Pas de GC, gestion mémoire via QTT (Quantitative Type Theory).
- Protocoles sûrs grâce à MPST (Multiparty Session Types).
- Capabilités comme mécanisme central de sécurité et de partage.
- Abstractions zéro‑cost.
- Auto‑hébergement : compilateur écrit en Heaven lui‑même.
- Proof assistant intégré et type‑driven development.
- Transpilation universelle (C, LLVM, WASM, BEAM, JVM, JS).
- Frugalité : estimation et gestion des ressources.

## Syntaxe
- Hindley–Milner avec un seul `:` pour les signatures.
- Types dépendants optionnels.
- Holes (`?impl`) pour le développement incrémental.

## Concurrence et distribution
- Acteurs isolés, communication par messages.
- MPST pour décrire les protocoles multi‑participants.
- libp2p comme couche réseau pour les échanges inter‑nœuds.

## Capabilités
- Inspirées de Pony (iso, val, ref, box/tag).
- Inspirées de Goblins (FsCap, NetCap, SpawnCap, etc.).
- Intégrées au type system et vérifiées statiquement.

## Tests et preuves
- Proof assistant intégré.
- Génération automatique de tests (QuickCheck).
- Développement guidé par les types.

## Frugalité
- Estimation statique des ressources (temps, mémoire, CPU, énergie).
- Gestion des budgets explicites.
