# Roadmap

Idées d’amélioration possibles pour la suite.

## Court terme

- Nettoyer les anciens README pour les aligner avec l’API actuelle `newX` plutôt que `addX`.
- Refactoriser `Core.Timer` pour travailler clairement en secondes.
- Ajouter un vrai module `Core.Settings` séparé de `Core.Options`.
- Ajouter des thèmes GUI simples : couleurs, fonts, padding, outline.
- Ajouter un widget `Toggle` visuel plus clair que texte `ON/OFF`.

## Moyen terme

- Ajouter `Core.Audio` pour gérer master/music/sfx séparément.
- Ajouter une pile de scènes ou overlays : pause menu, modal, popup.
- Ajouter un système de transition de scène : fade in/out.
- Ajouter un `Core.Debug` pour afficher FPS, scène courante, input mode, activeGroup.
- Ajouter un widget `List`, `Tabs`, `Checkbox`, `KeybindButton`.

## Long terme

- Ajouter un module `World` simple pour objets update/draw/destroy.
- Ajouter une caméra 2D.
- Ajouter des helpers de sauvegarde de profil.
- Ajouter un générateur de documentation automatique depuis les modules.
- Ajouter des tests minimaux avec `loadfile` / checks syntaxe.

## Principe à garder

Ne pas sur-engineerer.

Le moteur doit rester :

```txt
simple à lire
simple à modifier
simple à supprimer si un projet n’en a pas besoin
```
