# Broadcast sécurisé dans Heaven Core

Le broadcast sécurisé permet :

- la diffusion typée,
- la confidentialité,
- la résilience.

## API

```heaven
broadcastSecure : SecureGroup p -> Msg p -> Eff s s ()

## Propriétés
- chiffrement,
- intégrité,
- authentification.

## Distribution
Les groupes peuvent être :

- dynamiques,
- supervisés,
- fédérés.

## Visualisation
- graphes,
- heatmaps,
- logs.
