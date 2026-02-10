# Sémantique avancée de la logique dans Heaven Core

Heaven Core combine deux logiques :

- logique relationnelle (miniKanren),
- logique constructive (Curry–Howard).

## Logique relationnelle avancée

### Unification dépendante

L’unification peut impliquer :

- des indices,
- des raffinements,
- des contraintes arithmétiques.

### Recherche interleavée

Le scheduler logique :

- explore plusieurs branches,
- évite les blocages,
- respecte les budgets.

### Logique distribuée

Les goals peuvent être :

- sharded,
- migrés,
- parallélisés.

## Logique constructive avancée

### Preuves dépendantes

Les preuves peuvent dépendre :

- de valeurs,
- d’indices,
- de contraintes.

### Preuves effaçables

Les preuves sont effacées sauf si marquées `@[runtime]`.

### Interaction logique

La logique constructive peut raisonner sur les résultats relationnels.

