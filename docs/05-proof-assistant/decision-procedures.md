# Procédures de décision dans Heaven Core

Le proof assistant inclut des procédures de décision légères.

## Objectifs

- automatiser les preuves simples,
- éviter les recherches profondes,
- rester frugal.

## Procédures intégrées

### 1. Arithmétique de Presburger

- addition,
- comparaison,
- égalité.

### 2. Égalité structurelle

- listes,
- vecteurs,
- arbres.

### 3. Unification

- unification de Robinson,
- contraintes dépendantes.

### 4. Réécriture orientée

- règles `[simp]`,
- normalisation.

## Limitations

- pas de SAT/SMT complet,
- pas de logique du second ordre,
- pas de recherche exhaustive.

