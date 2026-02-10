# Runtime distribué d’Heaven Core

Heaven Core inclut un runtime distribué inspiré d’OTP, mais typé et frugal.

## Nœuds

Un nœud Heaven :

- exécute des fibres,
- possède un scheduler local,
- communique via des canaux typés,
- peut rejoindre un cluster.

## Canaux typés

Les canaux sont définis par un protocole :

```heaven
protocol PingPong =
  Ping : PingPong -> Pong
  Pong : PingPong -> Ping

