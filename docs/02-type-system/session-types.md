# Session Types dans Astra Core

Les session types décrivent des protocoles de communication typés.

## Syntaxe

```astra
protocol Chat =
  Hello : Chat -> Waiting
  Msg   : Waiting -> Waiting
  Bye   : Waiting -> End

