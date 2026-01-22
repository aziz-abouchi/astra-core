# Capacités dans Astra Core

Les capacités contrôlent l’accès aux effets.

## Types de capacités

- `FileCap` — accès aux fichiers
- `NetCap` — accès réseau
- `LockCap` — accès exclusif
- `LinearCap` — usage unique
- `AffineCap` — usage limité

## Exemple

```astra
readFile : FileCap -> Path -> String

