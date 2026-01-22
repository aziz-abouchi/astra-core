# Backpressure dans Astra Core

Le backpressure garantit :

- la stabilité des pipelines,
- la frugalité,
- l’absence de débordement mémoire.

## Modèle

Chaque flux possède :

- une capacité,
- un budget,
- un tampon typé.

## Mécanismes

### 1. Pull-based

Le consommateur demande les éléments.

### 2. Push-based

Le producteur envoie jusqu’à saturation.

### 3. Hybrid

Le runtime choisit dynamiquement.

## Backpressure typé

Les flux peuvent encoder leur capacité :

```astra
data Stream (cap : Nat) a = ...

