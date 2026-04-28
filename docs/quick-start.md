# Quick Start

Cette page montre le minimum pour créer une scène avec un bouton et naviguer vers une autre scène.

## 1. Créer une scène Menu

`scenes/scene_menu.lua` :

```lua
local menu = Core.Scene.new("Menu")

local page = Core.Gui.newPage("MenuPage")
local group = Core.Gui.newButtonGroup("Menu", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  spacing = 24,
})

page:addGroup("main", group)

Core.Gui.newButton("Play", 0, 0, 500, 50, group, function()
  Core.Scene.set(Game)
end)

Core.Gui.newButton("Quit", 0, 0, 500, 50, group, function()
  love.event.quit()
end)

function menu.load()
  group:load()
  group:selectIndex(1)
end

function menu.enter()
  page:show()
  page:setActiveGroup("main")
end

function menu.leave()
  page:hide()
end

function menu.update(dt)
  page:update(dt)
end

function menu.draw()
  page:draw()
end

function menu.mousepressed(x, y, button, istouch, presses)
  page:mousepressed(x, y, button, istouch, presses)
end

return menu
```

## 2. Créer une scène Game

`scenes/scene_game.lua` :

```lua
local game = Core.Scene.new("Game")

local player = {
  x = 640,
  y = 360,
  speed = 240,
}

function game.update(dt)
  local x = Core.Input.getAxis("horizontal")
  local y = Core.Input.getAxis("vertical")

  player.x = player.x + x * player.speed * dt
  player.y = player.y + y * player.speed * dt

  if Core.Input.pressed("cancel") then
    Core.Scene.set(Menu)
  end
end

function game.draw()
  love.graphics.circle("fill", player.x, player.y, 20)
end

return game
```

## 3. Déclarer les scènes

`scenes/init_scenes.lua` :

```lua
local f = "scenes/scene_"

Menu = require(f .. "menu")
Game = require(f .. "game")
Options = require(f .. "options")
```

## Résultat

- Souris : hover + clic.
- Clavier : haut / bas / entrée / échap.
- Manette : d-pad / stick / A / B.
- Le focus UI est géré automatiquement par `Core.Gui`.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
