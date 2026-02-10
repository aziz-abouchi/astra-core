# Session Types dans Heaven Core

Les session types décrivent des protocoles de communication typés.

## Syntaxe

```heaven
protocol Chat =
  Hello : Chat -> Waiting
  Msg   : Waiting -> Waiting
  Bye   : Waiting -> End

