# Zero-Cost Abstractions dans Heaven Core

Heaven Core garantit que les abstractions de haut niveau :

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

```heaven
head : Vect (S n) a -> a

