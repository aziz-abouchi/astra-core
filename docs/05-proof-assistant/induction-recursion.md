# Induction–Récursion dans Astra Core

Astra Core supporte les définitions induction–récursion :

- types définis inductivement,
- fonctions définies récursivement,
- dépendance mutuelle.

## Exemple

```astra
data U = ...
interp : U -> Type

