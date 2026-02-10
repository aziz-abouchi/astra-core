# Sémantique des effets dans Heaven Core

Les effets dans Heaven Core sont :

- **explicites** (jamais implicites),
- **contrôlés par les capacités**,
- **indexés** (suivi d’état dans les types),
- **frugaux** (budgets, supervision),
- **composables** (monadiques ou algébriques).

## Catégories d’effets

### 1. Effets purs
Aucun effet externe, aucune mutation.

```heaven
pure : a -> Eff s s a

