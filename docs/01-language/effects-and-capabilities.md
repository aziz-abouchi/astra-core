# Effets, capacités et contrôle de l’expressivité

Astra Core adopte un modèle d’effets **contrôlé par les types**, basé sur :

- les capacités,
- les types linéaires,
- les effets indexés.

## Capacités

Une capacité est une valeur qui autorise un effet :

```astra
data FileCap : Type
data NetCap  : Type

