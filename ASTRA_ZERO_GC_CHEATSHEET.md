# 🧠 Astra-Core : Cheat-Sheet Technique Zero-GC

Ce document définit les règles de gestion mémoire d'Astra basées sur la **Quantitative Type Theory (QTT)** et les **Capabilities**. Il remplace le besoin d'un Garbage Collector par une analyse statique stricte.

---

## 1. Les Règles de la QTT (Multiplicités)

La QTT permet au compilateur de savoir exactement combien de fois une ressource est consommée au cours de son cycle de vie.

| Multiplicité | Symbole | Nom | Comportement Mémoire |
| :--- | :--- | :--- | :--- |
| **Zéro** | $0$ | *Erased* | Uniquement présent au niveau des types. Aucune existence au runtime. |
| **Un** | $1$ | *Linear* | **Obligation de consommation unique.** Le compilateur insère un `free` automatique après l'usage. |
| **Plusieurs** | $\omega$ | *Unrestricted* | Utilisable sans limite de nombre. Souvent associé à des données immutables. |

> **Règle d'or :** Si une variable est déclarée avec une multiplicité de $1$, elle ne peut être ni dupliquée, ni ignorée.

---

## 2. Le Système de Capabilities (Sécurité Concurrentielle)

Les capabilities définissent les droits d'accès à une zone mémoire, empêchant les *data races* sans verrouillage global.



| Capability | Mutabilité | Partageable ? | Description |
| :--- | :--- | :--- | :--- |
| **iso** (Isolated) | ✅ Oui | 🔄 Transfert | Seule référence au monde. Modifiable. Transférable entre acteurs. |
| **val** (Value) | ❌ Non | ✅ Oui | Donnée immutable. Tout le monde peut lire, personne ne peut écrire. |
| **ref** (Reference) | ✅ Oui | ❌ Non | Mutable, mais limitée à l'acteur ou à la fonction locale. |
| **box** (Box) | ❌ Non | ❌ Non | Vue "lecture seule" d'une ressource qui pourrait être `ref` ou `val`. |

---

## 3. Logique de Libération Mémoire (Automate de Compilation)

Astra ne scanne pas la mémoire à l'exécution. Il planifie la libération à la compilation :

1.  **Analyse de portée :** Le compilateur suit chaque variable de multiplicité $1$.
2.  **Point de consommation :** Dès qu'une fonction "consomme" une ressource `1 iso`, la validité de la référence s'arrête.
3.  **Insertion de code :** Le générateur de code insère l'appel à la fonction de libération du Runtime Zig immédiatement après le dernier usage valide.

---

## 4. Principes du Bootstrap (Zig ↔ Astra)

Pour assurer la transition en douceur, le développement suit cette hiérarchie :

* **Niveau Zig (Infrastructure) :** Fournit les allocateurs bas niveau et le scheduler.
* **Niveau Astra (Logique) :** Définit les règles de haut niveau. 
* **Objectif :** Utiliser Astra pour écrire le Typechecker d'Astra. Cela prouve que le système de gestion mémoire est capable de gérer des structures de données complexes (arbres, graphes) sans fuite.

---

## 🛑 Interdictions Strictes
* **Pas de Pointer Arithmetic :** Toute manipulation mémoire doit passer par le système de types.
* **Pas de Global Mutable State :** Tout état partagé doit être protégé par une capability `val` ou encapsulé dans un Acteur.
