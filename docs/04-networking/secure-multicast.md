# Multicast sécurisé dans Heaven Core

Le multicast sécurisé permet :

- la diffusion typée,
- la confidentialité,
- la résilience.

## Groupes sécurisés

```heaven
data SecureGroup p = MkSecureGroup [SecureChannel p]

