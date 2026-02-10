# Grammaire noyau d’Heaven Core

Cette grammaire décrit le noyau du langage, en incluant :

- définitions de données et fonctions,
- expressions de base,
- bloc `calc` pour les preuves,
- sous-langage logique (`fresh`, `===`, `conde`).

> Note : la syntaxe est donnée en style EBNF simplifié, à affiner ensuite.

## Modules

```ebnf
Module      ::= "module" UIdent ModuleBody
ModuleBody  ::= "where" "{" TopDecl* "}"
TopDecl     ::= DataDecl | FuncDecl | ImportDecl
ImportDecl  ::= "import" QName

