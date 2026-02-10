# Sémantique avancée des protocoles dans Heaven Core

Les protocoles dans Heaven Core sont :

- typés,
- indexés par états,
- frugaux,
- distribués,
- vérifiés statiquement.

## Structure générale

```heaven
protocol FileP where
  Closed -> Open
  Open -> Closed

