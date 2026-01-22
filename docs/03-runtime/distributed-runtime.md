# Runtime distribué d’Astra Core

Astra Core inclut un runtime distribué inspiré d’OTP, mais typé et frugal.

## Nœuds

Un nœud Astra :

- exécute des fibres,
- possède un scheduler local,
- communique via des canaux typés,
- peut rejoindre un cluster.

## Canaux typés

Les canaux sont définis par un protocole :

```astra
protocol PingPong =
  Ping : PingPong -> Pong
  Pong : PingPong -> Ping

