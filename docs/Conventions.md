# Conventions

## Style général

Le moteur cherche à rester proche de LÖVE :

```lua
scene.update(dt)
scene.draw()
scene.mousepressed(...)
```

Pas de gros framework imposé, pas d’ECS obligatoire, pas de surcouche magique.

## Nommage

| Type | Convention |
|---|---|
| Module | `Core.Input`, `Core.Gui`, `Core.Scene` |
| Scène | `local game = Core.Scene.new("Game")` |
| Action input | `validate`, `cancel`, `attack` |
| Token input | `key:return`, `pad:a`, `mouse:1` |
| Groupe GUI | `MainMenu`, `OptionsGroup` |
| Page GUI | `MenuPage`, `OptionsPage` |

## Callbacks scène recommandés

```lua
function scene.load()
end

function scene.enter(previousScene)
end

function scene.leave(nextScene)
end

function scene.update(dt)
end

function scene.draw()
end
```

## Responsabilités

### Une scène doit :

- gérer sa logique ;
- appeler `page:update(dt)` et `page:draw()` si elle a une UI ;
- demander un changement de scène ;
- lire `Core.Input`.

### Une scène ne devrait pas :

- dessiner elle-même le contour actif des boutons ;
- décider si la souris ou la manette a priorité ;
- sauvegarder directement les options ;
- tester partout des touches brutes.

## Couleur graphics

Après tes draws personnalisés, pense à remettre :

```lua
love.graphics.setColor(1, 1, 1, 1)
```

Le Core possède un garde-fou qui remet en blanc, mais il affiche un warning si un draw laisse une autre couleur active.

## API lowercase

La version actuelle utilise plutôt :

```lua
Core.Scene.new("Menu")
Core.Scene.set(Game)
```

Évite de mélanger avec les anciens noms de style `New` ou `SetScene` si tu veux garder une API homogène.
