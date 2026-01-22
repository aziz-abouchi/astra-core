# Scheduler, non-déterminisme et logique

Le runtime d’Astra Core doit concilier :

- concurrence (acteurs, fibres, OTP-like),
- non-déterminisme contrôlé (miniKanren, `conde`),
- frugalité (pas d’explosion combinatoire incontrôlée).

## Modèle de base

Le scheduler gère des **fibres** (unités légères d’exécution) :

- chaque fibre a une pile, un environnement, un état,
- les fibres peuvent être locales ou distribuées,
- le scheduling est coopératif ou work-stealing selon la config.

## Non-déterminisme logique

Les goals logiques (`fresh`, `===`, `conde`) produisent un **flux de solutions**.

Deux approches possibles (non exclusives) :

1. **Interne à une fibre**  
   - La fibre gère une structure de recherche (pile/queue de choix).
   - `conde` crée des branches internes.
   - Le scheduler voit une seule fibre, mais avec un état de recherche.

2. **Externalisation des branches**  
   - Chaque branche de `conde` peut devenir une fibre distincte.
   - Le scheduler distribue les branches sur plusieurs workers.
   - Permet de paralléliser la recherche logique.

Astra peut combiner les deux selon le contexte et les annotations.

## Stratégie de recherche

Pour miniKanren, on privilégie une **recherche fair** (interleaving) :

- éviter de bloquer sur une branche infinie,
- explorer les branches de manière équilibrée.

Le runtime peut implémenter :

- une file de choix (BFS-like),
- ou une stratégie plus sophistiquée (priorités, budgets).

## Budgets et frugalité

Chaque fibre (ou branche logique) peut être associée à un **budget** :

- nombre maximal d’étapes,
- temps CPU,
- mémoire.

Si le budget est dépassé :

- la branche est suspendue, tronquée ou abandonnée,
- un résultat partiel ou une erreur contrôlée peut être retourné.

Cela évite que des recherches logiques non bornées saturent le système.

## Intégration avec OTP-like

Les acteurs / processus OTP-like peuvent :

- lancer des recherches logiques comme tâches internes,
- superviser des fibres de recherche,
- appliquer des politiques de restart / timeout.

Exemple :

- un service de résolution de Sudoku est un acteur,
- chaque requête crée une fibre de recherche logique,
- le scheduler distribue les fibres,
- le superviseur applique des timeouts.

## Distribution

Les branches de recherche peuvent être :

- confinées à un nœud,
- ou distribuées sur plusieurs nœuds (sharding de l’espace de recherche).

Le runtime distribué doit alors :

- sérialiser l’état logique (substitutions, buts restants),
- gérer les échecs de nœuds,
- éventuellement recombiner les résultats.

Ce lien entre **logique**, **scheduler** et **distribution** est illustré par les
exemples `logic_programming.astra` et les scénarios de microservices.

