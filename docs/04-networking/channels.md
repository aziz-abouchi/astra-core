# Canaux, protocoles et communication typée

La communication dans Heaven Core repose sur :

- des **canaux typés**,
- des **protocoles** décrits au niveau des types,
- des **capacités** pour contrôler l’accès.

## Canaux typés

Un canal est paramétré par un protocole :

```heaven
channel : Protocol -> Type

