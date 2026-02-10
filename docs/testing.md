# Testing

## Objectifs
- Automatiser la génération de tests.
- QuickCheck intégré.

## Exemple
```heaven
prop_lengthPreserved : Vec a n -> Bool
prop_lengthPreserved v = length (sort v) == length v

## Intégration
Tests dérivés des signatures.
Proof assistant + QuickCheck.
