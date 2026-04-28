# Recettes

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

Le groupe ignore automatiquement les boutons invisibles.

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

## Déplacement joueur clavier + manette

```lua
function player.update(dt)
  local x = Core.Input.getAxis("horizontal")
  local y = Core.Input.getAxis("vertical")

  player.x = player.x + x * player.speed * dt
  player.y = player.y + y * player.speed * dt
end
```

## Attaque remappable

```lua
if Core.Input.pressed("attack") then
  player:attack()
end
```

## Retour au menu depuis le jeu

```lua
if Core.Input.pressed("cancel") then
  Core.Scene.set(Menu)
end
```

## Option personnalisée avec slider

```lua
Core.Options.newSlider("screen_shake", "Screen shake", 0.5, 0, 1, 0.05, function(value)
  GameSettings.screenShake = value
end, true)
```

## Option personnalisée avec dropdown

```lua
Core.Options.newChoice("language", "Langue", {
  { label = "Français", value = "fr" },
  { label = "English", value = "en" },
}, 1, function(value)
  GameSettings.language = value
end)
```

## Remapper une action dans Options

```lua
Core.Options.newInput("attack", "Input : Attaque")
```

## Forcer le mode manette

```lua
Core.Gui.setInputMode("gamepad", true)
```

## Changer le délai entre périphériques

```lua
Core.Gui.setInputModeDelay(0.25)
```

## Récupérer la résolution virtuelle

```lua
local w, h = Core.getDimensions()
```
