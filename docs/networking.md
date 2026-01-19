# Networking

## Objectifs
- Communication inter-nœuds via libp2p.
- Transparence locale/distant.

## libp2p
- Transport agnostique (TCP, QUIC, WebRTC).
- Découverte automatique des pairs.
- Routage distribué (DHT, gossip).
- Sécurité intégrée.

## Intégration
- Acteurs adressés par NodeId + ActorId.
- MPST mappés sur protocoles libp2p.
- Capabilités réseau (DialCap, ListenCap, PubSubCap).

