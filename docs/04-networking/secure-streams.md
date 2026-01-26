# Streams sécurisés dans Astra Core

Les streams sécurisés permettent :

- la communication continue,
- la confidentialité,
- la résilience.

## API

```astra
openStream  : SecureCap k -> Eff s s (Stream k)
writeStream : Stream k -> Msg p -> Eff s s ()
readStream  : Stream k -> Eff s s (Maybe (Msg p))

