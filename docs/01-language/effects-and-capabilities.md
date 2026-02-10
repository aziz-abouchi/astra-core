# Effets, capacités et contrôle de l’expressivité

Heaven Core adopte un modèle d’effets **contrôlé par les types**, basé sur :

- les capacités,
- les types linéaires,
- les effets indexés.

## Capacités

Une capacité est une valeur qui autorise un effet :

```heaven
data FileCap : Type
data NetCap  : Type

