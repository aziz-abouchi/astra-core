# Sémantique avancée des effets dans Astra Core

Les effets avancés d’Astra Core combinent :

- effets indexés,
- capacités,
- logique relationnelle,
- distribution,
- frugalité.

## Effets algébriques

Les effets peuvent être définis comme des opérations :

```astra
effect Console where
  print : String -> Eff s s ()

