# Streams sécurisés dans Heaven Core

Les streams sécurisés permettent :

- la communication continue,
- la confidentialité,
- la résilience.

## API

```heaven
openStream  : SecureCap k -> Eff s s (Stream k)
writeStream : Stream k -> Msg p -> Eff s s ()
readStream  : Stream k -> Eff s s (Maybe (Msg p))

