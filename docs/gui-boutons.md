# GUI - Boutons

Cette page regroupe les exemples pratiques liés aux boutons, aux groupes de boutons et aux menus simples.

L'objectif est de garder une utilisation proche de LÖVE2D : peu de code dans les scènes, et une logique UI centralisée dans `Core.Gui`.

## Créer un bouton simple

```lua
local button = Core.Gui.newButton("Jouer", 0, 0, 500, 50, nav.group, function()
  Core.Scene.set(Game)
end)
```

Le callback est appelé quand le bouton est validé avec :

- la souris ;
- le clavier ;
- la manette.

## Créer un bouton Options dans le menu

```lua
Core.Gui.newButton("Options", 0, 0, 500, 50, nav.group, function()
  Core.Scene.set(Options)
end)
```

## Cacher un bouton débloqué plus tard

```lua
nav.credits = Core.Gui.newButton("Credits", 0, 0, 500, 50, nav.group, function()
  Core.Scene.set(Credits)
end)

nav.credits:setVisible(false)

function menu.setCreditsUnlocked(unlocked)
  nav.credits:setVisible(unlocked == true)
end
```

Un bouton invisible est ignoré par la navigation et par les clics souris.

## Désactiver temporairement un bouton

```lua
nav.continue:setEnabled(false)
```

Un bouton désactivé peut rester visible, mais il ne doit pas être validé.

## Menu vertical centré

```lua
local group = Core.Gui.newButtonGroup("MainMenu", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  spacing = 24,
})
```

## Menu avec espacement automatique

```lua
local group = Core.Gui.newButtonGroup("MainMenu", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  areaH = 360,
  spacing = "auto",
})
```

## Groupe actif

Un seul groupe doit recevoir la navigation clavier/manette à la fois.

```lua
Core.Gui.setActiveGroup(nav.group)
```

Pour récupérer le groupe actif :

```lua
local group = Core.Gui.getActiveGroup()
```

## Feedback visuel

Le feedback visuel est géré par le module GUI.

Une scène devrait simplement dessiner son groupe ou sa page :

```lua
function menu.draw()
  menu.page:draw()
end
```

La scène ne devrait pas dessiner elle-même le contour du bouton actif.

## Hover souris et navigation clavier/manette

Quand la souris survole un bouton, le groupe synchronise aussi son index de sélection.

Cela permet de passer proprement de la souris au clavier ou à la manette sans revenir à un ancien bouton sélectionné.

## Boutons dans une page GUI

```lua
local page = Core.Gui.newPage("MenuPage")
local group = Core.Gui.newButtonGroup("MainMenu")

page:addGroup("main", group)
page:setActiveGroup("main")
```

Ensuite, la scène peut rester simple :

```lua
function menu.update(dt)
  menu.page:update(dt)
end

function menu.draw()
  menu.page:draw()
end

function menu.mousepressed(x, y, button, istouch, presses)
  menu.page:mousepressed(x, y, button, istouch, presses)
end
```

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
