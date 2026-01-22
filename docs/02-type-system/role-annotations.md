# Annotations de rôle dans Astra Core

Les rôles permettent de contrôler la variance et la sécurité des types.

## Rôles disponibles

### 1. `nominal`
Aucune équivalence structurelle.

### 2. `representational`
Équivalence structurelle autorisée.

### 3. `phantom`
Le paramètre n’apparaît pas dans la représentation.

## Exemple

```astra
data Box (a : Type) @[role phantom] = MkBox Int

