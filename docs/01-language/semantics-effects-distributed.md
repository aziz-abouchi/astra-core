# Sémantique des effets distribués dans Astra Core

Les effets distribués permettent :

- l’exécution distante,
- la migration d’effets,
- la supervision inter-nœuds,
- la frugalité réseau.

## Effets distribués typés

```astra
remote : NodeId -> Eff s1 s2 a -> Eff s1 s2 a

