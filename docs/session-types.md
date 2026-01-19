# Multiparty Session Types (MPST)

## Objectifs
- Garantir la sûreté des protocoles concurrents et distribués.
- Vérification statique des échanges.

## Exemple
```astra
protocol Chat {
  Client -> Server : Login(username : String)
  Server -> Client : Welcome(message : String)
  repeat {
    Client -> Server : Send(text : String)
    Server -> Client : Ack
  }
}

## Intégration
Endpoints de session = ressources linéaires (QTT).
Protocoles exécutés via libp2p.
