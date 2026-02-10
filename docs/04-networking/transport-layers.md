# Couches de transport dans Heaven Core

Heaven Core supporte plusieurs couches de transport :

- TCP,
- UDP,
- QUIC,
- transports virtuels,
- transports fédérés.

## Abstraction typée

```heaven
data Transport (proto : Proto) = ...

