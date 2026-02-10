# IO distribués dans Heaven Core

Les IO distribués permettent :

- l’accès distant,
- la supervision,
- la frugalité.

## IO typés

```heaven
readRemote  : FileCap Read -> NodeId -> Path -> Eff s s String
writeRemote : FileCap Write -> NodeId -> Path -> String -> Eff s s ()

Propriétés
- pas d’effets implicites,
- capacités linéaires,
- sécurité.

Distribution
Les IO peuvent être :

- routés,
- migrés,
- supervisés.

Visualisation
- timelines,
- heatmaps,
- métriques.
