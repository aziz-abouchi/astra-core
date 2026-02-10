# Capacités distribuées

Les capacités distribuées permettent :

- le contrôle d’accès,
- la sécurité,
- la frugalité,
- la cohérence entre nœuds.

## Types de capacités

- **LocalCap** : ressource locale.
- **RemoteCap** : ressource distante.
- **LinearCap** : usage unique.
- **AffineCap** : usage limité.
- **PersistentCap** : lecture seule.

## Transfert de capacités

Le runtime garantit :

- pas de duplication,
- pas de fuite,
- pas de désynchronisation.

Les capacités sont sérialisées de manière sûre :

- cryptographie optionnelle,
- vérification de validité,
- expiration possible.

## Exemple

```heaven
send : RemoteCap -> Msg -> Eff s s ()
recv : RemoteCap -> Eff s s Msg

