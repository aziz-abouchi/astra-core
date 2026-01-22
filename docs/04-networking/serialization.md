# Sérialisation et transport dans Astra Core

La sérialisation est :

- typée,
- sûre,
- frugale,
- compatible avec les capacités.

## Formats

- binaire compact (par défaut),
- JSON optionnel (debug),
- formats spécialisés pour les vecteurs / arbres.

## Sérialisation typée

Chaque valeur sérialisée inclut :

- un identifiant de type,
- une représentation compacte,
- des métadonnées optionnelles.

## Capacités

Les capacités ne sont pas sérialisées comme des données :

- elles sont transformées en **tokens**,
- validés par le runtime distant,
- réhydratés en capacités locales.

## Protocoles

Les protocoles typés guident la sérialisation :

- chaque message a un type connu,
- les transitions sont vérifiées,
- les erreurs sont inexpressibles.

