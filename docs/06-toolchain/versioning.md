# Versioning dans Heaven Core

Heaven Core adopte un versioning reproductible et typé.

## Objectifs

- stabilité,
- compatibilité,
- reproductibilité.

## Versioning des modules

Chaque module possède :

- un hash de contenu,
- un hash de dépendances,
- une version dérivée automatiquement.

## Versioning des paquets

Basé sur :

- SemVer,
- compatibilité des types,
- compatibilité des preuves.

## Versioning des protocoles

Les protocoles sont versionnés via :

- leurs états,
- leurs transitions,
- leurs messages.

## Compatibilité

Le compilateur vérifie :

- la compatibilité ascendante,
- la compatibilité descendante,
- les invariants.

