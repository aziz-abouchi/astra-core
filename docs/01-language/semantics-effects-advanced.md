# Sémantique avancée des effets dans Heaven Core

Les effets avancés d’Heaven Core combinent :

- effets indexés,
- capacités,
- logique relationnelle,
- distribution,
- frugalité.

## Effets algébriques

Les effets peuvent être définis comme des opérations :

```heaven
effect Console where
  print : String -> Eff s s ()

