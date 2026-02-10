# RPC sécurisé dans Heaven Core

Les RPC sécurisés permettent :

- des appels typés,
- la confidentialité,
- la supervision.

## API

```heaven
rpc : SecureCap k -> NodeId -> Msg p -> Eff s s (Resp p)

