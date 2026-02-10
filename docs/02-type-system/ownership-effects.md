# Ownership et effets dans Heaven Core

Heaven Core relie ownership et effets pour garantir :

- sûreté,
- frugalité,
- absence de data races.

## Effets contrôlés par ownership

Une capacité linéaire donne accès à un effet :

```heaven
read : FileCap Read -> Eff s s String

