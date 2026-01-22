# Modèle d’IO dans Astra Core

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

```astra
readFile  : FileCap -> Path -> String
writeFile : FileCap -> Path -> String -> ()

