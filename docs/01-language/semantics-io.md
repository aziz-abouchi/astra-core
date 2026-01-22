# Sémantique des IO dans Astra Core

Les IO dans Astra Core sont :

- explicites,
- contrôlées par capacités,
- typées,
- frugales,
- distribuables.

## IO explicites

Aucun effet IO n’est implicite. Toute opération doit déclarer sa capacité :

```astra
readFile : FileCap Read -> Path -> Eff s s String

