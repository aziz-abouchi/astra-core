# Canaux, protocoles et communication typée

La communication dans Astra Core repose sur :

- des **canaux typés**,
- des **protocoles** décrits au niveau des types,
- des **capacités** pour contrôler l’accès.

## Canaux typés

Un canal est paramétré par un protocole :

```astra
channel : Protocol -> Type

