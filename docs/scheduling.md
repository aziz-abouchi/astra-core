# Scheduling & Work‑Stealing in Astra

## Objectifs du scheduler Astra
Le scheduler d’Astra est conçu pour offrir :
- une **concurrence massive**,
- une **distribution transparente** entre nœuds,
- une **frugalité** (respect des budgets de ressources),
- une **tolérance aux pannes**,
- un **équilibrage automatique** de la charge.

Astra combine **work‑stealing local** (entre threads) et **work‑stealing remote** (entre nœuds via libp2p).

---

# 1. Architecture générale du scheduler

## Modèle d’exécution
- Basé sur des **acteurs isolés**.
- Chaque acteur possède une **mailbox** et une **file de tâches**.
- Le scheduler gère :
  - les threads locaux,
  - les files de travail,
  - les transferts de tâches,
  - les budgets de ressources,
  - les protocoles MPST,
  - la communication libp2p.

## Composants
- **Worker Threads** : threads locaux qui exécutent les tâches.
- **Local Work Queues** : une file par thread.
- **Global Steal Queue** : file partagée pour équilibrage.
- **Remote Steal Manager** : coordination du work‑stealing entre nœuds.
- **Budget Manager** : vérifie les ressources disponibles.
- **MPST Coordinator** : garantit la sûreté des protocoles lors des migrations.

---

# 2. Work‑Stealing Local

## ⚙️ Principe
Chaque thread :
1. prend une tâche dans sa propre file,
2. si elle est vide, tente de voler une tâche dans la file d’un autre thread,
3. si toutes les files sont vides, il se met en veille légère.

## Avantages
- Utilisation optimale des cœurs CPU.
- Équilibrage automatique de la charge.
- Très faible overhead (zéro‑cost abstractions).
- Parfait pour les workloads massivement parallèles.

## Intégration avec QTT et capabilités
- Les valeurs linéaires (quantité 1) sont transférées en toute sécurité.
- Les capabilités contrôlent ce qu’un thread peut voler ou exécuter.

---

# 3. Work‑Stealing Remote (Distribué)

## Principe
Les nœuds Astra sont connectés via **libp2p**.  
Chaque nœud possède :
- ses propres acteurs,
- ses propres files de tâches,
- ses propres budgets de ressources.

Lorsqu’un nœud est surchargé :
1. il publie un signal de surcharge,
2. les nœuds sous‑utilisés proposent de voler des tâches,
3. les tâches migrent via libp2p,
4. MPST garantit que les protocoles restent corrects,
5. le Budget Manager vérifie que le nœud receveur peut exécuter la tâche.

## Conditions pour voler une tâche à distance
- Le nœud receveur doit avoir :
  - assez de **CPU**,
  - assez de **mémoire**,
  - assez d’**énergie**,
  - les **capabilités** nécessaires,
  - un **endpoint MPST compatible**.

## Tolérance aux pannes
Si un nœud tombe :
- ses tâches non terminées sont redistribuées,
- les protocoles MPST reprennent depuis l’état cohérent le plus récent,
- les ressources linéaires sont réassignées en respectant QTT.

---

# 4. Budgets & Frugalité dans le scheduling

## Rôle du Budget Manager
Avant d’exécuter ou de voler une tâche, Astra estime :
- le temps CPU nécessaire,
- la mémoire,
- l’énergie,
- les IO.

Si le budget est insuffisant :
- la tâche **n’est pas lancée**,
- ou **n’est pas volée**,
- ou est **renvoyée** au nœud d’origine.

## Exemple
```astra
runWithBudget task { cpu=50ms, mem=128MB, energy=10J }

