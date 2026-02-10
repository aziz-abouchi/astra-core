# Gestionnaire de paquets Heaven Core

Heaven Core inclut un gestionnaire de paquets frugal et reproductible.

## Objectifs

- installation simple,
- résolutions typées,
- reproductibilité totale,
- intégration CI.

## Fichier de configuration

```toml
[package]
name = "my-app"
version = "0.1.0"

[dependencies]
logic = ">=1.0"
net = ">=2.0"

