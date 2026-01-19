# Tools

## Objectifs

Astra doit fournir un ensemble minimal d’outils pour garantir un workflow complet et productif : interprétation, interaction, compilation, profilage et débogage.

## Interpréteur

Exécute directement du code Astra sans compilation préalable.

Utile pour prototypage rapide, scripts et tests exploratoires.

Basé sur l’IR interne d’Astra.

Respecte les capabilités et budgets de ressources.

## REPL (Read–Eval–Print Loop)

Interface interactive pour écrire et tester du code en direct.

Supporte les holes et le type‑driven development.

Intègre le proof assistant pour vérifier des preuves interactives.

Génère automatiquement des tests de propriétés.

##️ Compilateur

Cœur du projet, écrit en Astra lui‑même (auto‑hébergement).

Frontend : parsing, typechecking (QTT, MPST, capabilités).

Backend : transpilation vers C, LLVM, WASM, BEAM, JVM, JS.

Optimisations zéro‑cost : effacement des abstractions inutiles.

## Profileur

Analyse des performances : temps CPU, mémoire, énergie.

Intégré au modèle frugal : estimation statique + mesures dynamiques.

Compare l’estimation et la consommation réelle.

## Débuggeur

Débogage interactif des programmes Astra.

Support des acteurs et des protocoles MPST (visualisation des sessions).

Intégration avec capabilités : inspection limitée aux droits disponibles.

Fonctionne en mode distribué via libp2p.

## En résumé

Ces outils fondamentaux garantissent que chaque développeur Astra dispose d’un environnement complet :

Interpréteur pour exécution rapide.

REPL pour exploration interactive.

Compilateur pour production et transpilation.

Profileur pour optimisation et frugalité.

Débuggeur pour correction et compréhension des programmes.

Astra se positionne ainsi comme une plateforme complète, auto‑suffisante et tournée vers la productivité et la fiabilité.
