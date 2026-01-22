# Modalités graduées dans Astra Core

Les modalités graduées permettent :

- de contrôler l’usage,
- de modéliser la frugalité,
- de raisonner sur les ressources.

## Modalités principales

### 1. `!k A` — usage limité à k fois
Modélise une ressource réutilisable un nombre limité de fois.

### 2. `□ A` — usage illimité
Modélise une ressource persistante.

### 3. `◇ A` — usage éventuel
Modélise une ressource optionnelle.

## Exemple

```astra
f : !2 (FileCap Read) -> Eff s s String

