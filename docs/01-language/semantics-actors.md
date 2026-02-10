# Sémantique des acteurs dans Heaven Core

Heaven Core adopte un modèle d’acteurs :

- typé,
- supervisé,
- frugal,
- distribué.

## Acteurs

Un acteur est :

- une fibre avec état,
- une mailbox typée,
- un protocole explicite,
- une supervision.

## Sémantique des messages

Les messages :

- sont typés,
- suivent un protocole,
- ne peuvent pas violer l’état.

## Isolation

Les acteurs :

- ne partagent pas de mémoire mutable,
- communiquent uniquement par messages,
- utilisent des capacités pour les effets.

## Distribution

Les acteurs peuvent :

- migrer,
- se répliquer,
- être supervisés à distance.

## Déterminisme

En mode test :

- l’ordre des messages est fixé,
- le scheduling est déterministe,
- les transitions sont reproductibles.

