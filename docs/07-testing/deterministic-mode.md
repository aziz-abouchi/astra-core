# Mode déterministe pour les tests

Heaven Core peut exécuter le code en mode déterministe.

## Objectifs

- reproductibilité,
- tests fiables,
- vérification formelle.

## Effets du mode déterministe

- scheduling fixe,
- exploration logique contrôlée,
- seeds fixes pour les générateurs,
- ordre stable des fibres.

## Activation

- via flag du compilateur,
- via annotation de module,
- via REPL.

## Limitations

- performances réduites,
- pas de parallélisme non déterministe.

