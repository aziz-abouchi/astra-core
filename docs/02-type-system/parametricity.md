# Parametricité dans Astra Core

La parametricité garantit :

- l’uniformité,
- la sûreté,
- l’absence de comportements cachés.

## Principe

Une fonction polymorphe ne peut pas :

- inspecter ses arguments,
- dépendre de leur représentation,
- violer l’abstraction.

## Exemple

```astra
id : a -> a
id x = x

