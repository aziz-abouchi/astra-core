# Résolution de contraintes dans Heaven Core

Le système de contraintes d’Heaven Core est :

- dépendant,
- arithmétique,
- structurel,
- logique,
- distribué.

## Pipeline de résolution

1. **Collecte**  
   Le typechecker collecte toutes les contraintes générées.

2. **Simplification**  
   Normalisation, réécriture, propagation.

3. **Unification**  
   Unification dépendante, structurelle, logique.

4. **Résolution arithmétique**  
   Solveur Presburger intégré.

5. **Obligations de preuve**  
   Génération automatique de buts.

## Contraintes distribuées

Les contraintes peuvent être :

- locales,
- globales,
- synchronisées entre nœuds.

## Visualisation

- graphes de contraintes,
- logs,
- arbres de résolution.

