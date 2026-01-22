# Consensus dans Astra Core

Astra Core inclut un module de consensus typé pour :

- coordination,
- réplication,
- tolérance aux pannes.

## Algorithmes supportés

- Raft,
- Multi-Paxos,
- EPaxos (optionnel),
- CRDTs typés.

## Objectifs

- sécurité,
- cohérence,
- frugalité,
- intégration avec les capacités.

## API

```astra
propose : ConsensusCap -> Value -> Eff s s Result
read    : ConsensusCap -> Eff s s Value

