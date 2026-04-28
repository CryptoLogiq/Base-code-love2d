# Scènes

Le module `Core.Scene` gère les écrans du jeu : menu, jeu, options, loading, etc.

## Créer une scène

```lua
local menu = Core.Scene.new("Menu")

function menu.load()
end

function menu.enter(previousScene)
end

function menu.leave(nextScene)
end

function menu.update(dt)
end

function menu.draw()
end

return menu
```

## Cycle de vie

| Callback | Rôle |
|---|---|
| `load()` | appelé une seule fois avant la première utilisation |
| `enter(previousScene)` | appelé à chaque entrée dans la scène |
| `leave(nextScene)` | appelé quand on quitte la scène |
| `update(dt)` | logique de frame |
| `draw()` | rendu |
| `mousepressed(...)` | événements souris |
| `keypressed(...)` | événements clavier |
| `gamepadpressed(...)` | événements manette |

## Changer de scène

```lua
Core.Scene.set(Game)
```

Ou par nom :

```lua
Core.Scene.set("Game")
```

## Exemple avec retour menu

```lua
local game = Core.Scene.new("Game")

function game.update(dt)
  if Core.Input.pressed("cancel") then
    Core.Scene.set(Menu)
  end
end

function game.draw()
  love.graphics.print("Game", 100, 100)
end

return game
```

## Couleur de fond par scène

```lua
Core.Scene.setBackgroundColor(0.08, 0.08, 0.10, 1)
```

Quand tu changes de scène, le Core synchronise et réapplique la couleur de fond.

## Bonnes pratiques

Dans `enter()`, redonne le focus au groupe GUI principal :

```lua
function menu.enter()
  menu.page:show()
  menu.page:setActiveGroup("main")
end
```

Dans `leave()`, cache la page si nécessaire :

```lua
function menu.leave()
  menu.page:hide()
end
```

Cela évite que le focus d’une ancienne page reste actif après un changement de scène.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
