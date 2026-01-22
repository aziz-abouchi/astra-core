# Tolérance aux pannes dans Astra Core

Astra Core s’inspire d’OTP, mais avec des garanties typées.

## Supervision

Les superviseurs gèrent :

- fibres,
- acteurs,
- services distribués.

Stratégies :

- `one_for_one`,
- `rest_for_one`,
- `one_for_all`.

## Détection de pannes

Le runtime détecte :

- fibres bloquées,
- nœuds morts,
- canaux invalides,
- capacités expirées.

## Reprise

Les superviseurs peuvent :

- redémarrer une fibre,
- relancer un protocole,
- migrer une capacité,
- rétablir un état logique.

## Distribution

En cas de panne d’un nœud :

- les capacités linéaires sont invalidées,
- les capacités persistantes peuvent être répliquées,
- les fibres logiques peuvent être replanifiées ailleurs.

## Frugalité

Les politiques de reprise tiennent compte :

- des budgets,
- des priorités,
- des ressources disponibles.

