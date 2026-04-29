# AGENTS.md — Instructions pour les scènes

## Objectif du dossier

Le dossier `scenes/` contient les scènes du projet LÖVE2D.

Une scène doit rester simple, lisible et facile à comprendre.  
Le code doit être pédagogique, même pour quelqu’un qui découvre le projet.

## Règles générales

- Écrire du Lua simple et clair.
- Éviter les abstractions trop complexes.
- Ne pas refactorer toute une scène sans demande explicite.
- Modifier uniquement les fichiers nécessaires.
- Garder les scènes faciles à lire et à déboguer.
- Ne pas déplacer du code vers le core sans raison claire.
- Ne pas ajouter de dépendance externe.
- Préserver la logique existante du Scene Manager.

## Style recommandé

Préférer une structure de scène simple :

```lua
local Scene = {}

function Scene.load()
    -- Initialisation de la scène
end

function Scene.update(dt)
    -- Mise à jour de la logique
end

function Scene.draw()
    -- Affichage de la scène
end

function Scene.keypressed(key)
    -- Gestion clavier si nécessaire
end

function Scene.mousepressed(x, y, button)
    -- Gestion souris si nécessaire
end

return Scene
```
