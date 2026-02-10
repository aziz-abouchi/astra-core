# Méta-circularité dans Heaven Core

Heaven Core évite la méta-circularité dangereuse tout en permettant :

- la réflexion,
- la génération de preuves,
- la manipulation de termes.

## Pas de méta-circularité complète

Le proof assistant **ne peut pas** :

- se prouver lui-même,
- modifier son noyau,
- s’auto-valider.

## Réflexion contrôlée

Les termes peuvent être inspectés :

```heaven
quote : a -> Term a
unquote : Term a -> a

