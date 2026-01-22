# Panorama des exemples Astra Core

Les exemples fournis avec Astra Core ont un rôle central : ils servent à la fois
de **matériel d’onboarding**, de **validation de la spec** et de **démonstration
des capacités du langage**.

Ils couvrent six axes majeurs :

- **Concurrence & systèmes réactifs**
  - `reactive_systems.astra`
  - `data_pipelines.astra`
  - `microservices.astra`
- **Programmation logique & relationnelle**
  - `logic_programming.astra`
- **Développement guidé par les types**
  - `safe_protocols.astra`
- **Preuves formelles & vérification**
  - `verified_algorithms.astra`

## Reactive Systems (OTP)

Ces exemples démontrent :

- **Acteurs / processus supervisés**
- **Tolérance aux pannes**
- **Pipelines de données**
- **Microservices typés**

Ils illustrent l’intégration d’un modèle OTP-like dans Astra, avec un runtime
concurrent et distribué.

## Logic Programming (Prolog + miniKanren)

Fichier : `logic_programming.astra`

Démontre :

- Relations Prolog : faits, règles, requêtes
- miniKanren : `fresh`, unification `===`, `conde`
- Relations classiques : `appendo`, `membero`, `reverseo`
- Arithmétique de Peano logique
- Résolution de problèmes : Sudoku, N-reines
- Inférence de types Hindley–Milner en logique
- Unification (algorithme de Robinson)
- Logique au niveau des types (type-level logic)

Cet exemple montre comment Astra peut héberger un sous-langage logique
expressif, tout en restant intégré au type system global.

## Type-Driven Development (Types dépendants)

Fichier : `safe_protocols.astra`

Démontre :

- Vecteurs dimensionnés : `Vect n a` avec taille statique
- États typés : sockets/protocoles réseau avec états dans les types
- Machines à états au niveau des types (FSM)
- Preuves d’égalité : `sym`, `trans`, `cong`
- Preuves arithmétiques : commutativité, associativité
- Types raffinés : validation au niveau du type
- Types linéaires : ressources à usage unique
- Monades indexées : état initial/final dans le type
- Paires dépendantes : types `Sigma` existentiels

Cet exemple sert de vitrine au **type-driven development** dans Astra.

## Proof Assistant & Algorithmes vérifiés

Fichier : `verified_algorithms.astra`

Démontre :

- Preuves arithmétiques par raisonnement équationnel (`calc`)
- Preuves sur listes : `reverse (reverse xs) = xs`
- Correction d’algorithmes : tri par insertion prouvé correct
- Arbres équilibrés (AVL) avec preuve de préservation
- Terminaison : récursion bien fondée
- Sécurité : information flow prouvé sûr
- Curry–Howard : logique = types, preuves = programmes
- Compilateur vérifié : preuve de correction

Cet exemple illustre le **proof assistant intégré** et le style de preuve
recommandé dans Astra.

## Rôle de ces exemples dans la spec

Chaque exemple est un **point d’ancrage** pour la documentation :

- `logic_programming.astra` → langage logique, unification, HM, non-déterminisme.
- `safe_protocols.astra` → types dépendants, linéaires, indexés, protocoles typés.
- `verified_algorithms.astra` → proof assistant, style de preuve, Curry–Howard.

Ils servent de base à la définition formelle du langage, du type system et du
proof assistant.

