# Kinds de capacités dans Astra Core

Les capacités sont classées par kinds, ce qui permet :

- une meilleure sécurité,
- une meilleure modularité,
- une meilleure frugalité.

## Kinds principaux

### 1. `Linear`
Ressource consommée exactement une fois.

### 2. `Affine`
Ressource consommée au plus une fois.

### 3. `Persistent`
Ressource réutilisable.

## Kinds avancés

### 4. `Distributed`
Capacité utilisable sur plusieurs nœuds.

### 5. `Secure`
Capacité nécessitant une clé.

### 6. `Protocol`
Capacité représentant un état de protocole.

## Exemple

```astra
data FileCap : Mode -> Capability Linear

