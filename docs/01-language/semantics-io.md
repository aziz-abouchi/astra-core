# Sémantique des IO dans Heaven Core

Les IO dans Heaven Core sont :

- explicites,
- contrôlées par capacités,
- typées,
- frugales,
- distribuables.

## IO explicites

Aucun effet IO n’est implicite. Toute opération doit déclarer sa capacité :

```heaven
readFile : FileCap Read -> Path -> Eff s s String

