# Annotations de rôle dans Heaven Core

Les rôles permettent de contrôler la variance et la sécurité des types.

## Rôles disponibles

### 1. `nominal`
Aucune équivalence structurelle.

### 2. `representational`
Équivalence structurelle autorisée.

### 3. `phantom`
Le paramètre n’apparaît pas dans la représentation.

## Exemple

```heaven
data Box (a : Type) @[role phantom] = MkBox Int

