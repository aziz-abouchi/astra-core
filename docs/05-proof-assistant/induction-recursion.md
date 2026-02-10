# Induction–Récursion dans Heaven Core

Heaven Core supporte les définitions induction–récursion :

- types définis inductivement,
- fonctions définies récursivement,
- dépendance mutuelle.

## Exemple

```heaven
data U = ...
interp : U -> Type

