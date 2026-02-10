# Trace Replay dans Heaven Core

Le trace replay permet de :

- rejouer des exécutions,
- reproduire des bugs,
- tester la distribution.

## Types de traces

- scheduling,
- messages,
- transitions de protocole,
- substitutions miniKanren.

## Capture

Les traces sont :

- typées,
- compressées,
- déterministes.

## Replay

```heaven
replay : Trace -> Eff s s Result

