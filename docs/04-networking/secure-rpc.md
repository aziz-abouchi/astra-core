# RPC sécurisé dans Astra Core

Les RPC sécurisés permettent :

- des appels typés,
- la confidentialité,
- la supervision.

## API

```astra
rpc : SecureCap k -> NodeId -> Msg p -> Eff s s (Resp p)

