# Implications runtime des types dépendants et linéaires

Les features de haut niveau (types indexés, dépendants, linéaires) ont des
conséquences directes sur le runtime d’Astra Core.

## Erasure des preuves

Les preuves (valeurs de types logiques, e.g. `Eq a b`) sont :

- utilisées au **temps de compilation / typage**,
- effacées au **runtime**.

Le compilateur :

- peut conserver des preuves pour des optimisations,
- mais le runtime n’a pas besoin de représenter les preuves explicitement.

## Indices de types

Les indices (e.g. `Nat` dans `Vect n a`, `SocketState` dans `Socket s`) peuvent :

- être effacés si non nécessaires au runtime,
- ou être représentés de manière compacte si utilisés pour des décisions runtime.

Stratégie :

- par défaut, les indices sont effacés,
- sauf si marqués comme “runtime-relevant”.

## Types linéaires et gestion des ressources

Les types linéaires permettent au runtime d’avoir des garanties fortes :

- pas de double fermeture de socket,
- pas de fuite de handle,
- pas de partage non contrôlé.

Le compilateur peut :

- générer du code qui n’a pas besoin de checks dynamiques pour ces invariants,
- ou insérer des assertions en mode debug.

## Concurrence et capacités

Les capacités linéaires peuvent être utilisées pour :

- modéliser des permissions d’accès à des ressources concurrentes,
- garantir qu’un lock est détenu par un seul thread logique à la fois.

Le runtime peut exploiter ces garanties pour :

- simplifier les structures de synchronisation,
- éviter certains verrous ou checks.

## Frugalité et budget de ressources

Les types indexés et linéaires s’intègrent avec le modèle de frugalité :

- un type peut encoder un budget (e.g. “au plus N étapes”),
- une ressource linéaire peut représenter un “token de budget”.

Le runtime peut alors :

- suivre la consommation de ressources,
- déclencher des stratégies de dégradation ou d’arrêt contrôlé.

