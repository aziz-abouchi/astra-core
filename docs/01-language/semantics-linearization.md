# Sémantique de la linéarisation dans Astra Core

La linéarisation garantit :

- l’absence de duplication de ressources,
- la frugalité,
- la sûreté mémoire,
- la cohérence des protocoles.

## Linéarité des valeurs

Une valeur linéaire doit être :

- consommée exactement une fois,
- transférée explicitement,
- jamais copiée.

## Linéarité des capacités

Les capacités linéaires contrôlent :

- les IO,
- les régions,
- les protocoles,
- les transports.

## Linéarisation des effets

Les effets linéaires imposent :

- un ordre strict,
- une consommation unique,
- une absence de fuite.

## Linéarisation distribuée

Lors de la migration :

- les capacités sont transférées,
- les régions sont déplacées,
- les protocoles sont préservés.

## Visualisation

- graphes de linéarité,
- logs,
- diagnostics.

