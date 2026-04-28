# GUI Focus / Page / Group

Modifs intégrées :

- `Core.Gui.activeGroup`
- `Core.Gui.setActiveGroup(group)`
- `Core.Gui.getActiveGroup()`
- `Core.Gui.clearActiveGroup(group)`
- `Core.Gui.Page.new(name)` / alias `Core.Gui.Panel`
- `Gui.Group` avec `active`, `visible`, `enabled`, `hovered`, `visualCurrent`
- `Gui.Button` avec `hovered`, `selected`, `enabled`, `visible`, `callback/fct`

## Principe

Plusieurs groupes peuvent être visibles, mais un seul groupe reçoit la navigation clavier/manette.

```lua
Core.Gui.setActiveGroup(myGroup)
```

La souris peut cliquer sur un groupe visible même s'il n'est pas actif : le clic donne le focus au groupe, sélectionne le bouton et lance son callback.

## Utilisation simple dans une scène

```lua
local page = Core.Gui.Page.new("OptionsPage")
local audioGroup = Core.Gui.button.newGroup("AudioButtons")

page:addGroup("audio", audioGroup)

Core.Gui.button.new("Volume -", 100, 100, 250, 50, audioGroup, function(self)
  print("volume down")
end)

Core.Gui.button.new("Volume +", 100, 170, 250, 50, audioGroup, function(self)
  print("volume up")
end)

function scene.load()
  page:setActiveGroup("audio")
end

function scene.update(dt)
  page:update(dt)
end

function scene.draw()
  page:draw()
end

function scene.mousepressed(x, y, button, istouch, presses)
  page:mousepressed(x, y, button, istouch, presses)
end
```

## Important

La scène ne dessine plus le contour vert elle-même.
Le contour est géré automatiquement par `group:draw()` :

- si un bouton est survolé, le contour va sur le bouton survolé ;
- sinon, le contour va sur le bouton sélectionné du groupe actif ;
- les groupes inactifs ne réagissent pas au clavier/manette.
