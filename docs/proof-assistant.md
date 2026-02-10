# Proof Assistant

## Objectifs
- Vérification formelle intégrée.
- Types dépendants + QTT.
- Preuves effacées au runtime.

## Exemple
```heaven
sort : Vec a n -> Vec a n
proof sortPreservesLength : ∀ v. length (sort v) = length v

## Intégration
Holes pour preuves partielles.
Proof search.
Tactiques inspirées de Coq/Agda.
