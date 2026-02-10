# Modèle d’IO dans Heaven Core

Le modèle d’IO est :

- typé,
- frugal,
- compatible avec les capacités,
- intégrable au runtime distribué.

## Principes

- les IO nécessitent des capacités (`FileCap`, `NetCap`, etc.),
- les IO sont des effets indexés,
- les IO peuvent être linéaires (usage unique).

## Opérations

### Fichiers

```heaven
readFile  : FileCap -> Path -> String
writeFile : FileCap -> Path -> String -> ()

