# Sémantique des effets dans Astra Core

Les effets dans Astra Core sont :

- **explicites** (jamais implicites),
- **contrôlés par les capacités**,
- **indexés** (suivi d’état dans les types),
- **frugaux** (budgets, supervision),
- **composables** (monadiques ou algébriques).

## Catégories d’effets

### 1. Effets purs
Aucun effet externe, aucune mutation.

```astra
pure : a -> Eff s s a

