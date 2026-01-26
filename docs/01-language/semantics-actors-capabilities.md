# Sémantique acteurs + capacités dans Astra Core

Astra Core unifie le modèle d’acteurs et le système de capacités pour garantir :

- sûreté,
- frugalité,
- distribution contrôlée,
- absence d’effets implicites.

## Capacités d’acteurs

Chaque acteur possède :

- une mailbox typée,
- un protocole d’état,
- un ensemble de capacités linéaires ou affines.

## Envoi de messages

```astra
send : ActorCap p -> Msg p -> Eff s s ()

