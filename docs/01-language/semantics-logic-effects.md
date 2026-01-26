# Sémantique des effets logiques dans Astra Core

Astra Core unifie :

- les effets algébriques,
- la logique relationnelle (miniKanren),
- la distribution,
- la frugalité.

## Effets logiques

Les effets logiques permettent :

- la génération de branches,
- la propagation de substitutions,
- la résolution de contraintes.

```astra
fresh : Logic a
choose : [a] -> Logic a

