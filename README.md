# Heaven

[![Zig](https://img.shields.io/badge/Zig-0.15.2-orange.svg)](https://ziglang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active_Deployment-brightgreen.svg)]()

**Langage et système d'exploitation pour essaims de réplicants autonomes (Von Neumann probes).**

Heaven est une plateforme de calcul distribué conçue pour survivre et s'étendre dans l'espace profond. Il repose sur un **noyau minimal de 6 primitives** qui permet de représenter mathématiques, logique, preuves, musique, bioinformatique et philosophie, tout en garantissant la correction formelle et l'optimisation énergétique.

---

## Noyau minimal : 6 primitives fondamentales

Le langage est construit autour de seulement 6 constructions. Tout le reste est dérivé automatiquement.

| Primitive    | Rôle                              | Implémentation                                      |
|--------------|-----------------------------------|-----------------------------------------------------|
| **Symbol**   | Objet atomique                    | `src/saturation/egraph.zig` (nœuds)                 |
| **Bind**     | Liaison / variable                | `src/lens/mod.zig` + `ir.zig`                       |
| **Apply**    | Application                       | `src/saturation/mirror.zig` + `forge/mod.zig`       |
| **Aggregate**| Opérateurs mathématiques (Σ Π ∫)  | `src/saturation/library.zig`                        |
| **Relation** | Contraintes logiques              | En cours (prévu dans `neural/`)                     |
| **Query**    | Résolution / recherche            | En cours (prévu dans `neural/`)                     |

---

## Exemples concrets

### Factorielle avec budget QTT

```heaven
factorial : (n : Nat) -> { budget: Time < 500ms, Energy < 10mJ } -> Nat
factorial Z = 1
factorial (S k) = Apply(*, (S k), factorial k)
```

> Transformé en e-graph → optimisé par le Brain → généré dans 10 langages via forge.

### Physique

```heaven
F = Apply(*, m, a)
```

### Logique

```heaven
Human(x) ⇒ Mortal(x)   -- Relation(implies, Human(x), Mortal(x))  [en cours]
```

### Recherche (miniKanren style)

```heaven
appendo xs ys zs = conde
  [ xs === [] /\ ys === zs
  , fresh $ \h t r => xs === (h::t) /\ zs === (h::r) /\ appendo t ys r ]
```

---

## Architecture

```
src/
├── lens/          # parsing immutable (Bind + Symbol)
├── saturation/    # e-graph + Mirror + Gupi (EQSAT + auto-derivation)
├── neural/        # Brain (IA embarquée qui guide la saturation)
├── forge/         # hub de transpilation (10 langages : Zig, Rust, Python, Fortran, WASM, Forth…)
├── ir/            # représentation intermédiaire
├── main.zig       # pipeline complet : Lens → Brain → Saturation → Forge
├── runtime/       # acteurs + supervision (holographique)
└── compiler/      # hm.zig (Hindley-Milner en cours)
```

---

## Pipeline complet (`run.sh`)

```sh
./run.sh
# 1. zig build
# 2. Lens.parse → e-graph
# 3. Brain.guideSaturation + gupi.meditate
# 4. Forge.emit pour 10 langages
# 5. Tests automatiques (JS, Python, Fortran, WASM, Forth…)
# 6. Option --serve → visualiseur web en direct
```

---

## Moteurs fondamentaux

| Moteur                        | État                                           |
|-------------------------------|------------------------------------------------|
| Type inference (Hindley-Milner) | `compiler/hm.zig` — stub actif               |
| EQSAT / e-graph rewriting     | `src/saturation/` — opérationnel, guidé par IA |
| Moteur logique (miniKanren)   | En cours — prévu dans `neural/`                |

---

## Exemples avancés

### Vecteur type-dépendant

```heaven
head : Vect (S n) a -> a
head (x :: xs) = x   -- head [] rejeté à la compilation
```

### Preuve formelle intégrée

```heaven
plusCommutative : (n : Nat) -> (m : Nat) -> n + m = m + n
plusCommutative Z m = sym (plusZeroRightNeutral m)
```

### Pipeline réactif

```heaven
logPipeline : Stream LogEntry -> Stream Alert
logPipeline = filter ... >>> map ... >>> window ... >>> tap ...
```

---

## Démarrage rapide

```sh
git clone https://github.com/aziz-abouchi/astra-core
cd astra-core
./run.sh          # pipeline complet + tests
./run.sh --serve  # visualiseur web en direct
```

---

## Statut (12 mars 2026)

- ✅ Pipeline complet fonctionnel (parsing → Brain → EQSAT → transpilation)
- 🔧 Noyau auto-dérivant et holographique en cours de maturation
- ✅ 10 langages testés automatiquement
- ✅ Visualiseur web intégré

Heaven n'est plus une idée théorique : c'est un compilateur expérimental qui construit déjà le noyau minimal de 6 primitives et qui dérive le reste via IA + e-graph.

---

## Contributions prioritaires

- `Relation` + `Query` (miniKanren)
- Types exprimés comme relations
- Bibliothèque standard

---

> **Heaven — Un noyau de 6 primitives qui dérive l'univers entier.**