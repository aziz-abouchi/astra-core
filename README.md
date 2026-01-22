# Astra-Core

[![Zig](https://img.shields.io/badge/Zig-0.15.2-orange.svg)](https://ziglang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

**Langage et plateforme fonctionnel réactif orienté concurrence, parallélisme et distribution**

Astra est un langage de programmation innovant qui combine les paradigmes les plus puissants pour créer des systèmes distribués fiables, performants et vérifiés formellement.

## 🌟 Philosophie

Astra fusionne le meilleur de plusieurs mondes :

- **Erlang/OTP** : Modèle d'acteurs, tolérance aux pannes, distribution
- **Idris2** : Types dépendants, inférence Hindley-Milner, preuves formelles
- **Prolog** : Programmation logique, relations, unification
- **miniKanren** : Logique relationnelle, recherche exhaustive
- **Pony** : Système de capabilities pour la sécurité mémoire

Le résultat : un langage où **la correction est garantie par le système de types**, **la concurrence est native et sûre**, et **la logique est un citoyen de première classe**.

## ✨ Caractéristiques principales

### 🎭 OTP Behaviors intégrés

Astra intègre nativement les patterns éprouvés d'Erlang/OTP :

```astra
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

```astra
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

```astra
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

```astra
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

```astra
-- Pipeline de traitement
logPipeline : Stream LogEntry -> Stream Alert
logPipeline =
  filter (\e => e.level /= Debug)
  >>> map enrichWithContext
  >>> window (minutes 1) computeStatistics
  >>> tap detectAnomaly
  >>> branch handleByLevel
```

## 🚀 Démarrage rapide

### Installation

```bash
# Prérequis : Zig 0.15.2
curl https://ziglang.org/download/0.15.2/... | tar -xJ

# Cloner Astra
git clone https://github.com/aziz-abouchi/astra-core.git
cd astra-core

# Compiler
zig build

# Tester
zig build test
```

### Premier programme

```astra
-- hello.astra
module Main

import System.IO

main : IO ()
main = putStrLn "Hello, Astra!"
```

```bash
astra build hello.astra
./hello
```

### Premier GenServer

```astra
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

## 🏗️ Architecture

```
astra-core/
├── src/               # Compilateur Astra (Zig)
│   ├── parser/        # Analyseur syntaxique
│   ├── typechecker/   # Vérificateur de types
│   ├── eqsat/         # Optimisations EQSAT
│   └── codegen/       # Génération de code
├── runtime/           # Runtime Astra
│   ├── otp/           # Implémentation OTP
│   ├── scheduler/     # Ordonnanceur d'acteurs
│   └── gc/            # Garbage collector
├── stdlib/            # Bibliothèque standard
├── examples/          # Exemples et tutoriels
├── tests/             # Suite de tests
├── docs/              # Documentation
├── tools/             # Outillage (LSP, formatter)
└── vendor/            # Dépendances externes
```

## 🔧 Optimisations EQSAT

Astra utilise **Equality Saturation** (e-graphs) pour des optimisations puissantes :

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
astra check examples/06-proof-assistant/

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

Astra s'inspire de recherches académiques :

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

- **Issues** : [GitHub Issues](https://github.com/aziz-abouchi/astra-core/issues)
- **Discussions** : [GitHub Discussions](https://github.com/aziz-abouchi/astra-core/discussions)
- **Email** : [maintainer email]

---

**Astra** - *Where types meet actors, and logic meets distribution*

**Status** : En développement actif | Zig 0.15.2 | Contributions bienvenues