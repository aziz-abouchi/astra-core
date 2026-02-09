# Heaven (formerly Astra-Core)

[![Zig](https://img.shields.io/badge/Zig-0.15.2-orange.svg)](https://ziglang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-DeepSpace_Deployment-brightgreen.svg)]()

**Système d'exploitation et langage de programmation pour essaims de réplicants (Sondes de Von Neumann).**

Heaven est une plateforme de calcul distribué conçue pour la survie et l'expansion autonome dans l'espace profond. Il fusionne la vérification formelle, la gestion stricte des ressources énergétiques et l'intelligence artificielle auto-apprenante au sein d'un écosystème unique.

## 🌌 Philosophie : La Survie par la Rigueur

Dans Heaven, chaque cycle CPU et chaque joule d'énergie est une ressource finie dont la consommation doit être prouvée statiquement. Le projet repose sur quatre piliers :

1. **Vérification Quantitative (QTT)** : Utilisation de la *Quantitative Type Theory* pour garantir que les budgets de mission (Temps, Mémoire, Énergie) ne sont jamais dépassés.
2. **Conscience Artificielle (oLlama ou équivalent)** : Un moteur d'IA embarqué assiste le compilateur dans la résolution de preuves complexes et optimise l'interpréteur en temps réel.
3. **Optimisation EQSAT** : Réduction drastique de l'empreinte énergétique via la saturation d'égalité (e-graphs).
4. **Interopérabilité Universelle** : Un hub de transpilation bidirectionnel supportant 16 langages cibles pour coloniser n'importe quel environnement technique.

Heaven fusionne le meilleur de plusieurs mondes :

- **Erlang/OTP** : Modèle d'acteurs, tolérance aux pannes, distribution
- **Idris2** : Types dépendants, inférence Hindley-Milner, preuves formelles
- **Prolog** : Programmation logique, relations, unification
- **miniKanren** : Logique relationnelle, recherche exhaustive
- **Pony** : Système de capabilities pour la sécurité mémoire

Le résultat : un langage où **la correction est garantie par le système de types**, **la concurrence est native et sûre**, et **la logique est un citoyen de première classe**.

## ✨ Caractéristiques de Mission

### 📊 Budgets de Mission (QTT)
Heaven impose une sémantique de ressources linéaires. Un objet possédant une "consommation" ne peut être dupliqué sans preuve d'énergie disponible.

### 🤖 IA Co-Pilot (Distributed oLlama)
L'IA n'est pas un outil externe, mais un composant du runtime :
- **Aide aux preuves** : Résolution automatique des trous de type (*holes*).
- **Mapping sémantique** : Aide à la transpilation entre Heaven et les 16 langages supportés.
- **Auto-optimisation** : Réécriture du code machine en fonction des métriques de l'essaim.

### 🔌 Hub de Transpilation (16 cibles)
Conversion bidirectionnelle fluide entre Heaven et :
*Zig, C, Rust, Python, Erlang, Agda, Lean, Go, WASM, LLVM-IR, Haskell, Java, PHP, Swift, OCaml, C++.*

### 🎭 OTP Behaviors intégrés

Heaven intègre nativement les patterns éprouvés d'Erlang/OTP :

```heaven
behavior WeatherStation : GenServer Call Cast Info State where
  init config = do
    logInfo "Starting weather station"
    pure $ InitOk initialState (seconds 60)
 
  handleCall GetTemperature from state = do
    temp <- readSensor
    pure $ Reply temp state
 
  handleCast (UpdateThreshold newThreshold) state =
    pure $ NoReply (record { threshold = newThreshold } state)
```

**Supervision trees**, **GenServers**, **Applications** : tout l'écosystème OTP est disponible avec la sûreté des types.

### 🔒 Pony Capabilities

Sécurité mémoire garantie au niveau du type :

```heaven
behavior CacheService : GenServer Call Cast Info State
  with cacheCapability : ref    -- Mutable partagé
     , configCapability : val   -- Immutable
     , tokenCapability : iso    -- Unique, transférable
```

- **`iso`** : Référence unique, ownership exclusif
- **`val`** : Immutable, partageable sans risque
- **`ref`** : Mutable avec synchronisation contrôlée
- **`tag`** : Opaque, pour identité uniquement

### 🧠 Programmation logique

Prolog et miniKanren intégrés pour la recherche et l'inférence :

```heaven
-- Style Prolog
rule $ \x, y =>
  Ancestor x y :- Parent x y

rule $ \x, y =>
  Ancestor x y :-
    fresh $ \z =>
      Parent x z /\ Ancestor z y

-- Style miniKanren
appendo : List a -> List a -> List a -> Goal
appendo xs ys zs = conde
  [ xs === [] /\ ys === zs
  , fresh $ \h, t, r =>
      xs === (h :: t) /\
      zs === (h :: r) /\
      appendo t ys r
  ]
```

### 📐 Types dépendants

Vecteurs dimensionnés, protocoles type-safe, preuves formelles :

```heaven
-- Vecteur de taille n (connue statiquement)
head : Vect (S n) a -> a
head (x :: xs) = x
-- head [] est REJETÉ à la compilation !

-- Protocole réseau type-safe
data ConnectionState = Closed | Open | Authenticated
data Socket : ConnectionState -> Type

connect : Socket Closed -> IO (Socket Open)
authenticate : Socket Open -> Credentials -> IO (Socket Authenticated)
send : Socket Authenticated -> Data -> IO ()
-- Impossible d'envoyer sur une socket non authentifiée !

-- Preuve formelle
plusCommutative : (n : Nat) -> (m : Nat) -> n + m = m + n
plusCommutative Z m = sym (plusZeroRightNeutral m)
plusCommutative (S k) m =
  calc
    S k + m ={ Refl }= S (k + m)
            ={ cong S (plusCommutative k m) }= S (m + k)
            ={ sym (plusSuccRightSucc m k) }= m + S k
            QED
```

### ⚡ Concurrence réactive

Streams, pipelines, acteurs distribués :

```heaven
-- Pipeline de traitement
logPipeline : Stream LogEntry -> Stream Alert
logPipeline =
  filter (\e => e.level /= Debug)
  >>> map enrichWithContext
  >>> window (minutes 1) computeStatistics
  >>> tap detectAnomaly
  >>> branch handleByLevel
```

## 🏗️ Architecture des Dossiers

```
heaven/
 ├── src/               # Compilateur Heaven (Zig)
 │   ├── parser/        # Analyseur syntaxique (Grammaire Heaven)
 │   ├── typechecker/   # Vérificateur QTT (Quantitative Type Theory)
 │   ├── eqsat/         # Optimiseur e-graphs (Consommation Énergie)
 │   ├── codegen/       # Générateurs de code (Multi-target)
 │   └── ai_engine/     # Interface oLlama (Inférence compilateur)
 ├── runtime/           # Runtime Heaven
 │   ├── otp/           # Implémentation OTP
 │   ├── scheduler/     # Ordonnanceur d'acteurs/d'essaim (Work-stealing)
 │   ├── metrics/       # Dashboard temps-réel (Consommation Joules)
 │   └── safety/        # Isolation mémoire (Capabilities)
 ├── stdlib/            # Bibliothèque standard (Communication inter-sondes)
 ├── tools/             # Outillage (Hub de transpilation, LSP, formatter)
 ├── tests/             # Suite de tests
 ├── docs/              # Documentation
 └── examples/          # Exemples, tutoriels, Protocoles de mission (.heaven)
```

## 📐 Exemple : Factorielle avec Budget de Mission

Le code suivant prouve statiquement qu'il s'exécutera en moins de 500ms et n'utilisera pas plus de 10 mJ.

```heaven
module Math.Surveillance

-- Définition avec clauses de budget strictes
factorial : (n : Nat) -> { budget: Time < 500ms, Energy < 10mJ } -> Nat
factorial Z = 1
factorial (S k) = (S k) * factorial k

main : Mission ()
main = do
  res <- factorial 10
  logMission "Résultat calculé avec succès pour l'essaim."

///////////////////////////////

## 🚀 Démarrage rapide

### Installation

```bash
# Prérequis : Zig 0.15.2
curl https://ziglang.org/download/0.15.2/... | tar -xJ

# Cloner Heaven
git clone https://github.com/aziz-abouchi/heaven.git
cd heaven

# Compiler
zig build

# Tester
zig build test
```

### Premier programme

```heaven
-- hello.heaven
module Main

import System.IO

main : IO ()
main = putStrLn "Hello, Heaven!"
```

```bash
heaven build hello.heaven
./hello
```

### Premier GenServer

```heaven
module Counter

import OTP.GenServer

data CounterCall = GetCount
data CounterCast = Increment | Decrement

behavior Counter : GenServer CounterCall CounterCast () Nat where
  init () = pure $ InitOk 0
  
  handleCall GetCount from state =
    pure $ Reply state state
  
  handleCast Increment state =
    pure $ NoReply (state + 1)
  
  handleCast Decrement state =
    pure $ NoReply (state - 1)

main : IO ()
main = do
  pid <- GenServer.start Counter ()
  GenServer.cast pid Increment
  count <- GenServer.call pid GetCount (seconds 5)
  putStrLn "Count: \{show count}"
```

## 📚 Documentation

- **[Guide de démarrage](docs/getting-started.md)** - Installation et premiers pas
- **[Référence du langage](docs/language-reference.md)** - Syntaxe et sémantique
- **[OTP Behaviors](docs/otp-behaviors.md)** - GenServer, Supervisor, Application
- **[Pony Capabilities](docs/capabilities.md)** - Système de références sûres
- **[Programmation logique](docs/logic-programming.md)** - Prolog et miniKanren
- **[Types dépendants](docs/dependent-types.md)** - Type-driven development
- **[Exemples](examples/)** - Code annotés et tutoriels

## 🎯 Cas d'usage

### Systèmes distribués
- Microservices avec tolérance aux pannes
- Systèmes temps-réel (IoT, télécommunications)
- Architectures event-driven
- Message brokers et pipelines de données

### Applications critiques
- Systèmes embarqués vérifiés
- Protocoles cryptographiques prouvés
- Compilateurs certifiés
- Systèmes de contrôle avec safety guarantees

### Intelligence artificielle
- Systèmes experts avec logique relationnelle
- Résolution de contraintes
- Planification avec miniKanren
- Analyse de programmes avec e-graphs (EQSAT)

## 🔧 Optimisations EQSAT

Heaven utilise **Equality Saturation** (e-graphs) pour des optimisations puissantes :

```bash
# Compiler avec optimisations EQSAT
zig build -Doptimize=ReleaseFast
./zig-out/bin/extraction_example
```

Les e-graphs permettent :
- Optimisations algébriques automatiques
- Fusion de boucles
- Élimination de code mort
- Simplifications symboliques

## 🧪 Tests et vérification

```bash
# Tests unitaires
zig build test

# Tests d'intégration
zig build test-integration

# Vérification des preuves
heaven check examples/06-proof-assistant/

# Benchmark
zig build bench
```

## 🌐 Écosystème

- **LSP** : Intégration IDE (VS Code, Neovim, Emacs)
- **Tree-sitter** : Coloration syntaxique
- **Dashboard** : Monitoring des systèmes distribués
- **REPL** : Interface interactive
- **Package manager** : Gestion de dépendances

## 🤝 Contribuer

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](CONTRIBUTING.md).

### Domaines prioritaires

- [ ] Amélioration du typechecker
- [ ] Bibliothèque standard (networking, crypto)
- [ ] Exemples et tutoriels
- [ ] Documentation
- [ ] Optimisations runtime
- [ ] Outils de développement

## 📖 Publications et références

Heaven s'inspire de recherches académiques :

- **Erlang/OTP** : Armstrong, J. (2003). "Making reliable distributed systems in the presence of software errors"
- **Idris2** : Brady, E. (2021). "Idris 2: Quantitative Type Theory in Practice"
- **miniKanren** : Byrd, W. (2009). "Relational Programming in miniKanren"
- **Pony** : Clebsch, S. (2015). "Deny Capabilities for Safe, Fast Actors"
- **EQSAT** : Willsey, M. (2021). "egg: Fast and Extensible Equality Saturation"

## 📄 Licence

MIT License - voir [LICENSE](LICENSE) pour les détails.

## 🙏 Remerciements

- L'équipe Zig pour un excellent langage de systèmes
- La communauté Erlang/OTP pour 30+ ans de production-proven patterns
- Les créateurs d'Idris, Agda, Lean pour les types dépendants
- L'équipe Pony pour les capabilities
- Les chercheurs en programmation logique

## 📬 Contact

- **Issues** : [GitHub Issues](https://github.com/aziz-abouchi/heaven/issues)
- **Discussions** : [GitHub Discussions](https://github.com/aziz-abouchi/heaven/discussions)
- **Email** : [maintainer email]

---

**Heaven** - *Where types meet actors, and logic meets distribution*

**Status** : En développement actif | Zig 0.15.2 | Contributions bienvenues
