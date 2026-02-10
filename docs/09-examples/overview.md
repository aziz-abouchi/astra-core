# Panorama des exemples Heaven Core

Les exemples fournis avec Heaven Core ont un rôle central : ils servent à la fois
de **matériel d’onboarding**, de **validation de la spec** et de **démonstration
des capacités du langage**.

Ils couvrent six axes majeurs :

- **Concurrence & systèmes réactifs**
  - `reactive_systems.heaven`
  - `data_pipelines.heaven`
  - `microservices.heaven`
- **Programmation logique & relationnelle**
  - `logic_programming.heaven`
- **Développement guidé par les types**
  - `safe_protocols.heaven`
- **Preuves formelles & vérification**
  - `verified_algorithms.heaven`

## Reactive Systems (OTP)

Ces exemples démontrent :

- **Acteurs / processus supervisés**
- **Tolérance aux pannes**
- **Pipelines de données**
- **Microservices typés**

Ils illustrent l’intégration d’un modèle OTP-like dans Heaven, avec un runtime
concurrent et distribué.

## Logic Programming (Prolog + miniKanren)

Fichier : `logic_programming.heaven`

Démontre :

- Relations Prolog : faits, règles, requêtes
- miniKanren : `fresh`, unification `===`, `conde`
- Relations classiques : `appendo`, `membero`, `reverseo`
- Arithmétique de Peano logique
- Résolution de problèmes : Sudoku, N-reines
- Inférence de types Hindley–Milner en logique
- Unification (algorithme de Robinson)
- Logique au niveau des types (type-level logic)

Cet exemple montre comment Heaven peut héberger un sous-langage logique
expressif, tout en restant intégré au type system global.

## Type-Driven Development (Types dépendants)

Fichier : `safe_protocols.heaven`

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

Cet exemple sert de vitrine au **type-driven development** dans Heaven.

## Proof Assistant & Algorithmes vérifiés

Fichier : `verified_algorithms.heaven`

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
recommandé dans Heaven.

## Rôle de ces exemples dans la spec

Chaque exemple est un **point d’ancrage** pour la documentation :

- `logic_programming.heaven` → langage logique, unification, HM, non-déterminisme.
- `safe_protocols.heaven` → types dépendants, linéaires, indexés, protocoles typés.
- `verified_algorithms.heaven` → proof assistant, style de preuve, Curry–Howard.

Ils servent de base à la définition formelle du langage, du type system et du
proof assistant.

