# Philosophie d’Astra Core

Astra Core est un langage conçu pour un monde où les ressources sont limitées,
les systèmes sont distribués, et la sûreté est non négociable.

Son objectif est de concilier trois exigences rarement réunies :

1. **Frugalité** — chaque abstraction doit être mesurable, prédictible et optimisable.
2. **Concurrence sûre** — les programmes doivent être naturellement parallèles et
   distribués, sans data races ni comportements indéterministes.
3. **Preuves intégrées** — le langage doit permettre de vérifier statiquement
   les propriétés essentielles des programmes, sans sacrifier l’ergonomie.

Astra repose sur un type system expressif, un runtime déterministe, et un modèle
de ressources explicite. Le langage vise à rendre les programmes non seulement
corrects, mais également *prouvés*, *prévisibles* et *économes*.
