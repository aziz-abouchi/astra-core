# Ownership et Borrowing dans Astra Core

Astra Core combine :

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

```astra
borrow : Resource -> (Borrowed Resource -> a) -> a

