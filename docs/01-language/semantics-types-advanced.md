# Sémantique avancée des types dans Astra Core

Astra Core étend la sémantique des types avec :

- des invariants riches,
- des indices effaçables,
- des capacités,
- des protocoles,
- des raffinements,
- des types fantômes,
- des types quotient.

## Types comme invariants exécutables

Chaque type encode un invariant :

- `Vect n a` encode la taille,
- `Sorted xs` encode l’ordre,
- `Socket s` encode l’état réseau,
- `Eff s1 s2 a` encode une transition.

## Types dépendants avancés

Les types peuvent dépendre :

- de valeurs,
- de preuves,
- d’indices,
- de capacités.

Exemple :

```astra
safeHead : Vect (S n) a -> a

