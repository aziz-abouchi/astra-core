# Style de preuve dans Heaven Core

Heaven Core adopte un style de preuve **équationnel** inspiré de la tradition
Curry–Howard : les preuves sont des programmes, et les programmes peuvent être
raisonnés de manière calculatoire.

## Le bloc `calc`

Le mot-clé `calc` introduit une preuve par réécriture séquentielle :

```heaven
calc
  S k + right
    ={ Refl }=
  S (k + right)
    ={ cong S (plusCommutative k right) }=
  S (right + k)
    ={ sym (plusSuccRightSucc right k) }=
  right + S k
    QED

