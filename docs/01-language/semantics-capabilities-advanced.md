# Sémantique avancée des capacités dans Heaven Core

Les capacités sont le mécanisme central de contrôle des effets dans Heaven Core.
Elles garantissent :

- la sûreté,
- la frugalité,
- la distribution contrôlée,
- l’absence d’effets implicites.

## Types de capacités

### 1. Capacités linéaires
Consommées exactement une fois.

### 2. Capacités affines
Consommées au plus une fois.

### 3. Capacités persistantes
Réutilisables sans restriction.

### 4. Capacités sécurisées
Associées à une clé ou un secret.

### 5. Capacités distribuées
Valides sur plusieurs nœuds.

## Transitions de capacités

Les capacités peuvent évoluer :

```heaven
open : FileCap Closed -> Eff s s (FileCap Open)
close : FileCap Open -> Eff s s (FileCap Closed)

