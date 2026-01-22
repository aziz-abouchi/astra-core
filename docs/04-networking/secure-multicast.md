# Multicast sécurisé dans Astra Core

Le multicast sécurisé permet :

- la diffusion typée,
- la confidentialité,
- la résilience.

## Groupes sécurisés

```astra
data SecureGroup p = MkSecureGroup [SecureChannel p]

