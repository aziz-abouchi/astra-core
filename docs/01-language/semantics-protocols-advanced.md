# Sémantique avancée des protocoles dans Astra Core

Les protocoles dans Astra Core sont :

- typés,
- indexés par états,
- frugaux,
- distribués,
- vérifiés statiquement.

## Structure générale

```astra
protocol FileP where
  Closed -> Open
  Open -> Closed

