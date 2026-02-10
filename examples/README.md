# Exemples Heaven-Core

Ce dossier contient des exemples d'utilisation du langage Heaven pour différents cas d'usage, démontrant l'intégration des **OTP behaviors d'Erlang** et des **capabilities de Pony**.

## À propos d'Heaven

Heaven est un langage fonctionnel réactif fortement inspiré de :
- **Idris2** : Système de types dépendants et inférence Hindley-Milner
- **Erlang** : Modèle d'acteurs, OTP behaviors, tolérance aux pannes, distribution
- **Prolog** : Programmation logique et unification
- **miniKanren** : Logique relationnelle et recherche
- **Pony** : Capabilities (références avec garanties de sécurité)

## Caractéristiques principales

### OTP Behaviors (d'Erlang)

Heaven intègre les patterns éprouvés d'OTP :

#### GenServer
Serveur générique avec callbacks standards :
```heaven
behavior MyService : GenServer CallMsg CastMsg InfoMsg State where
  init : Config -> Effect (InitResult State)
  handleCall : CallMsg -> From -> State -> Effect (CallResult State)
  handleCast : CastMsg -> State -> Effect (CastResult State)
  handleInfo : InfoMsg -> State -> Effect (InfoResult State)
  terminate : Reason -> State -> Effect ()
```

#### Supervisor
Gestion de la tolérance aux pannes avec stratégies :
```heaven
supervisor = MkSupervisor
  { strategy = OneForOne  -- ou OneForAll, RestForOne
  , intensity = 10        -- Max restarts
  , period = seconds 60   -- Dans cette période
  , children = [...]
  }
```

#### Application
Lifecycle d'application avec supervision tree :
```heaven
behavior MyApp : Application where
  start : StartType -> List String -> Effect (Either Error Pid)
  stop : AppState -> Effect ()
```

### Pony Capabilities

Système de références avec garanties de sécurité au niveau du type :

```heaven
behavior Service : GenServer Call Cast Info State
  with capability1 : iso   -- Isolated (unique)
     , capability2 : val   -- Value (immutable partagé)
     , capability3 : ref   -- Reference (mutable partagé)
     , capability4 : tag   -- Tag (opaque, pas de lecture/écriture)
```

**Types de capabilities :**
- `iso` : Référence unique, peut être déplacée
- `val` : Immutable, peut être partagé en lecture
- `ref` : Mutable, partagé avec contrôle
- `tag` : Opaque, pour identité uniquement

### Signatures de type

Heaven utilise `:` comme séparateur unique (style Idris/Haskell) :

```heaven
-- Fonction simple
add : Int -> Int -> Int
add x y = x + y

-- Type polymorphe
map : (a -> b) -> List a -> List b

-- Avec contraintes
sort : Ord a => List a -> List a
```

### Inférence Hindley-Milner

Le système de types infère automatiquement :

```heaven
-- Type inféré : a -> a
identity x = x

-- Type inféré : Num a => a -> a -> a
multiply x y = x * y
```

### Pattern matching direct

Sans `case of` redondant (style Haskell/Erlang) :

```heaven
-- Pattern matching sur les paramètres
handleMessage (Init loc) state = ...
handleMessage Measure state = ...
handleMessage GetStats state = ...

-- Avec guards
processLog entry
  | entry.level == Critical = handleCritical entry
  | entry.level == Error = handleError entry
  | otherwise = handleNormal entry
```

## Structure des exemples

```
examples/
├── 01-reactive-systems/     # Acteurs, GenServer, Supervisor
│   ├── weather_station.heaven
│   └── README.md
├── 02-data-pipelines/       # Pipelines, OTP, miniKanren
│   ├── log_pipeline_with_otp.heaven
│   └── README.md
├── 03-microservices/        # Application behavior, distribution
│   ├── user_service_with_otp.heaven
│   └── README.md
├── 04-real-time/            # À venir
├── 05-parallel-computing/   # À venir
├── 06-iot-edge/             # À venir
└── 07-webassembly/          # À venir
```

## Exemples détaillés

### 1. Station Météo (OTP complet)

`01-reactive-systems/weather_station.heaven`

**Démontre :**
- GenServer pour les acteurs (WeatherStation, AlertService, Dashboard)
- Supervisor avec stratégie `OneForOne`
- Application behavior pour lifecycle
- Distribution sur cluster Erlang
- Pattern matching direct sans `case of`
- Pony capability `iso` pour l'affichage

**Architecture :**
```
WeatherApp (Application)
  └── Supervisor (OneForOne)
       ├── WeatherStationServer (GenServer, permanent)
       ├── AlertServer (GenServer, transient)
       └── Dashboard (GenServer, temporary)
```

**Exécution :**
```bash
zig build example -Dname=weather_station
./zig-out/bin/weather_station
```

### 2. Pipeline de Logs (OTP + miniKanren)

`02-data-pipelines/log_pipeline_with_otp.heaven`

**Démontre :**
- GenServer pour traitement par batch
- Supervisor avec `RestForOne` (cascade restart)
- Pool de workers avec load balancing
- miniKanren pour détection de patterns
- Pony capabilities (`val` pour logique, `ref` pour métriques)
- Timers et scheduling OTP

**Architecture :**
```
LogPipelineApp (Application)
  ├── Pipeline Supervisor (RestForOne)
  │    ├── LogProcessor (GenServer)
  │    ├── PatternDetector (GenServer + miniKanren)
  │    └── MetricsCollector (GenServer)
  └── Pool Supervisor (OneForOne)
       ├── LogProcessor #1
       ├── LogProcessor #2
       └── ...
```

**Concepts OTP :**
- Worker pool pattern
- Cascade restart strategy
- Message passing entre GenServers
- Distribution round-robin

### 3. Microservice REST (Production-ready)

`03-microservices/user_service_with_otp.heaven`

**Démontre :**
- Application behavior complète
- Supervision tree avec multiple supervisors
- Circuit breaker comme GenServer
- Pool de handlers HTTP
- Pony capabilities (`iso` pour permissions, `ref` pour cache)
- Call/Cast/Info patterns
- Graceful shutdown

**Architecture :**
```
UserManagementApp (Application)
  └── Microservice Supervisor (OneForOne)
       ├── UserService (GenServer + cache + DB)
       ├── PermissionService (GenServer)
       ├── CircuitBreaker (GenServer)
       └── HTTP Pool Supervisor (OneForOne)
            ├── HttpHandler #1 (transient)
            ├── HttpHandler #2 (transient)
            └── ...
```

**Patterns OTP :**
- Nested supervisors
- Worker restart strategies (permanent/transient/temporary)
- Synchronous calls avec timeout
- Asynchronous casts
- Info messages pour timers

## Patterns OTP expliqués

### Restart Strategies

**OneForOne** : Si un child crash, le redémarrer seul
```heaven
strategy = OneForOne
```

**OneForAll** : Si un child crash, redémarrer TOUS les children
```heaven
strategy = OneForAll
```

**RestForOne** : Si un child crash, redémarrer lui et tous les suivants
```heaven
strategy = RestForOne  -- Cascade
```

### Child Restart Types

**Permanent** : Toujours redémarré, peu importe la raison
```heaven
worker "critical_service" (...) Permanent (seconds 5)
```

**Transient** : Redémarré seulement si termine anormalement
```heaven
worker "http_handler" (...) Transient (seconds 5)
```

**Temporary** : Jamais redémarré automatiquement
```heaven
worker "one_shot_task" (...) Temporary (seconds 5)
```

### GenServer Call vs Cast

**Call** : Synchrone avec réponse
```heaven
result <- GenServer.call serverPid GetData (seconds 5)
```

**Cast** : Asynchrone sans réponse (fire and forget)
```heaven
GenServer.cast serverPid (UpdateData newData)
```

## Capabilities Pony expliquées

### Isolation (`iso`)
Référence unique, ownership exclusif :
```heaven
with fileCapability : iso
```
- Une seule référence existe
- Peut être déplacée mais pas copiée
- Garantit l'absence de data races

### Valeur (`val`)
Immutable partageable :
```heaven
with configCapability : val
```
- Lecture seule
- Peut être partagé entre acteurs
- Thread-safe par construction

### Référence (`ref`)
Mutable partageable avec contrôle :
```heaven
with cacheCapability : ref
```
- Lecture/écriture
- Partagé avec synchronisation
- Contrôlé par le type system

### Tag (`tag`)
Opaque, pour identité :
```heaven
with tokenCapability : tag
```
- Pas de lecture/écriture
- Juste pour identification
- Ultra-léger

## Compilation et exécution

```bash
# Compiler tous les exemples
zig build examples

# Compiler un exemple spécifique
zig build example -Dname=weather_station

# Exécuter
./zig-out/bin/weather_station

# Tests
zig test examples/01-reactive-systems/weather_station.heaven
```

## Distribution Erlang

Les exemples utilisent la distribution Erlang :

```bash
# Démarrer un nœud
heaven run weather_station --name sensor-node@localhost --cookie secret

# Se connecter à un cluster
heaven run --name processing-node@localhost --connect sensor-node@localhost
```

## Ressources

- [Documentation OTP Erlang](https://erlang.org/doc/design_principles/users_guide.html)
- [Pony Capabilities](https://tutorial.ponylang.io/capabilities/)
- [Idris2](https://idris2.readthedocs.io/)
- [miniKanren](http://minikanren.org/)

## Contribution

Pour ajouter des exemples :
1. Suivre la structure OTP (Application > Supervisor > Workers)
2. Utiliser les behaviors appropriés
3. Documenter les capabilities utilisées
4. Inclure des tests
5. Ajouter un README explicatif
