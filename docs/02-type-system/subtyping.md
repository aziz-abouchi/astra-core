# Sous-typage dans Heaven Core

Heaven Core adopte un sous-typage **structuré**, **limité**, et **prévisible**.

## Principes

- pas de sous-typage implicite généralisé,
- uniquement des relations sûres,
- pas de surprises pour le compilateur.

## Sous-typage autorisé

### 1. Sous-typage des capacités

```heaven
LinearCap <: AffineCap <: PersistentCap

