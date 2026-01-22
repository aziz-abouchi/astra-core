# Sémantique des acteurs distribués dans Astra Core

Les acteurs distribués sont un pilier d’Astra Core. Ils combinent :

- isolation stricte,
- protocoles typés,
- supervision,
- migration,
- frugalité.

## Identité distribuée

Chaque acteur possède :

- un `ActorId` global,
- un nœud d’attache,
- un protocole d’état.

## Mailboxes distribuées

Les mailboxes sont :

- typées,
- routées automatiquement,
- supervisées.

## Migration

Les acteurs peuvent migrer :

- pour réduire la latence,
- pour équilibrer la charge,
- pour se rapprocher des données.

La migration est :

- typée,
- supervisée,
- zero-copy lorsque possible.

## Réplication

Les acteurs critiques peuvent être :

- répliqués,
- synchronisés,
- supervisés.

## Visualisation

- graphes d’acteurs,
- heatmaps de migration,
- timelines.

