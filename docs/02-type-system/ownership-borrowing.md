# Ownership et Borrowing dans Heaven Core

Heaven Core combine :

- ownership linéaire,
- borrowing affine,
- régions,
- capacités.

## Ownership

Une ressource linéaire :

- ne peut pas être copiée,
- doit être consommée exactement une fois.

## Borrowing

Les prêts sont :

- temporaires,
- immuables,
- vérifiés statiquement.

```heaven
borrow : Resource -> (Borrowed Resource -> a) -> a

