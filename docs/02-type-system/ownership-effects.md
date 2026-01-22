# Ownership et effets dans Astra Core

Astra Core relie ownership et effets pour garantir :

- sûreté,
- frugalité,
- absence de data races.

## Effets contrôlés par ownership

Une capacité linéaire donne accès à un effet :

```astra
read : FileCap Read -> Eff s s String

