# Variance avancée dans Heaven Core

La variance détermine comment les types réagissent au sous-typage.

## Variance des fonctions

```text
(A1 -> B1) <: (A2 -> B2)
si A2 <: A1 (contravariant)
et B1 <: B2 (covariant)

