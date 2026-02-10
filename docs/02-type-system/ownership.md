# Ownership et aliasing contrôlé

Heaven Core adopte un modèle d’ownership inspiré de Rust, adapté :

- aux types linéaires,
- à la distribution,
- à la frugalité.

## Principes

- Chaque ressource a un **propriétaire** unique.
- Le propriétaire peut :
  - transférer l’ownership,
  - prêter des références (lecture seule ou contrôlée),
  - détruire la ressource.

## Aliasing

Les alias sont :

- sûrs pour les données immuables,
- contrôlés pour les données mutables (via capacités / types linéaires).

## Mouvement

Le mouvement est un transfert d’ownership :

```heaven
useOnce : Resource ⊸ Result

