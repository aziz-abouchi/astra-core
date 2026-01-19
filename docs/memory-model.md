# Memory Model

## Principes
- Pas de GC global.
- Gestion mémoire via QTT (Quantitative Type Theory).
- Quantités :
  - 0 : valeur fantôme (preuves, types).
  - 1 : linéaire (utilisée exactement une fois).
  - ω : usage libre.

## Ressources
- Ressources linéaires pour sockets, fichiers, buffers.
- Ownership et borrowing inspirés de Rust/Pony.
- Régions et arènes pour allocations groupées.

## Concurrence
- Valeurs linéaires transférées entre acteurs.
- Valeurs immuables partagées sans risque.
