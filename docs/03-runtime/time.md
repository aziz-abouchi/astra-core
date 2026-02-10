# Gestion du temps dans Heaven Core

Le runtime fournit une gestion du temps :

- frugale,
- déterministe optionnelle,
- distribuée.

## Horloges

Chaque nœud possède :

- une horloge monotone,
- une horloge murale,
- une horloge logique.

## Timers

```heaven
setTimer : Duration -> Eff s s TimerId
cancel   : TimerId -> Eff s s ()

