# Zero-Cost Abstractions dans Astra Core

Astra Core garantit que les abstractions de haut niveau :

- types dépendants,
- preuves,
- raffinements,
- capacités,

sont **effacées** ou **optimisées** pour ne rien coûter au runtime.

## Principes

1. **Erasure**  
   Les preuves et indices sont effacés sauf si marqués runtime-relevant.

2. **Inlining agressif**  
   Les fonctions purement structurelles sont inlinées.

3. **Fusion**  
   Les constructions intermédiaires sont éliminées.

4. **Spécialisation**  
   Les fonctions dépendantes sont spécialisées selon les indices.

## Exemples

### Vecteurs dimensionnés

```astra
head : Vect (S n) a -> a

