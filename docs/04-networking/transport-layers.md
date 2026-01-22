# Couches de transport dans Astra Core

Astra Core supporte plusieurs couches de transport :

- TCP,
- UDP,
- QUIC,
- transports virtuels,
- transports fédérés.

## Abstraction typée

```astra
data Transport (proto : Proto) = ...

