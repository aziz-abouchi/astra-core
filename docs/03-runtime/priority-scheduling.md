# Scheduling par priorité dans Heaven Core

Le scheduler peut attribuer des priorités aux fibres.

## Types de priorités

- `Low`
- `Normal`
- `High`
- `Critical`

## Annotation

```heaven
@[priority High]
compute x

