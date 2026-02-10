# Élaboration des termes dans Heaven Core

L’élaboration transforme :

- la syntaxe utilisateur,
- en syntaxe interne,
- avec insertion implicite,
- et résolution de contraintes.

## Étapes

1. résolution des noms,
2. inférence des types,
3. insertion des implicites,
4. génération des contraintes,
5. élaboration des preuves.

## Élaboration dépendante

Les indices sont :

- inférés,
- résolus,
- normalisés.

## Élaboration logique

Les goals miniKanren sont :

- encapsulés,
- typés,
- intégrés dans `Eff`.

