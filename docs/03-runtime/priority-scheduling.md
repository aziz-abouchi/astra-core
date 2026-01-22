# Scheduling par priorité dans Astra Core

Le scheduler peut attribuer des priorités aux fibres.

## Types de priorités

- `Low`
- `Normal`
- `High`
- `Critical`

## Annotation

```astra
@[priority High]
compute x

