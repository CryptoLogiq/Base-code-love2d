# GUI - Pages, groupes et boutons

Le GUI est structuré en trois niveaux :

```txt
Page / Panel
└─ Group
   └─ Button
```

## Pourquoi cette structure ?

Plusieurs groupes peuvent être visibles en même temps, mais un seul groupe doit recevoir la navigation clavier/manette.

Exemple :

```txt
OptionsPage
├─ TabsGroup
└─ AudioGroup
```

La souris peut cliquer sur n’importe quel groupe visible, mais le clavier et la manette naviguent seulement dans le groupe actif.

## Créer une page

```lua
local page = Core.Gui.newPage("MenuPage")
```

Aliases :

```lua
Core.Gui.Page
Core.Gui.Panel
Core.Gui.newPanel(...)
```

## Créer un groupe

```lua
local group = Core.Gui.newButtonGroup("Menu", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  spacing = 24,
})

page:addGroup("main", group)
```

## Créer un bouton

```lua
Core.Gui.newButton("Options", 0, 0, 500, 50, group, function(self)
  Core.Scene.set(Options)
end)
```

## Activer un groupe

```lua
page:setActiveGroup("main")
```

ou directement :

```lua
Core.Gui.setActiveGroup(group)
```

## Cycle dans une scène

```lua
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
```

## États d’un bouton

| État | Rôle |
|---|---|
| `visible` | affiché ou non |
| `enabled` | cliquable / sélectionnable ou non |
| `hovered` | souris dessus |
| `selected` | sélection logique clavier/manette |
| `visualActive` | feedback visuel final |

`visualActive` garantit qu’un seul bouton reçoit le feedback principal.

## Méthodes utiles bouton

```lua
button:setVisible(true)
button:setEnabled(false)
button:setText("Nouveau texte")
button:setFont(font)
button:setTextAlign("left", 14)
button:onClick(function(self)
  print(self.name)
end)
```

## Méthodes utiles groupe

```lua
group:selectIndex(1)
group:selectNext()
group:selectPrevious()
group:selectFirstAvailable()
group:validate()
group:setVisible(true)
group:setEnabled(true)
group:setActive(true)
```

## Layout automatique

Vertical :

```lua
group:layoutVertical("center", 200, 20, 500, 50)
```

Horizontal :

```lua
group:layoutHorizontal(100, 100, 16, 180, 50)
```

Ou à la création :

```lua
local group = Core.Gui.newButtonGroup("Main", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  areaH = 360,
  spacing = "auto",
})
```

## Dessin du focus

La scène ne dessine pas le contour elle-même. Le groupe le fait dans `group:draw()`.

```lua
function menu.draw()
  page:draw()
end
```

Personnalisation :

```lua
group.outlineColor = {0, 1, 0, 1}
group.outlineWidth = 2
group.outlinePadding = 4
group.outlineVisible = true
```
