# Options

`Core.Options` permet de générer une scène d’options fonctionnelle à partir d’une petite API.

Il utilise en interne :

```txt
Core.Gui.Page
Core.Gui.Group
Core.Gui.Button
Core.Input
love.window
love.audio
love.filesystem
```

## Exemple complet

```lua
local optionsScene = Core.Scene.new("Options")

local function goBackToMenu()
  Core.Scene.set(Menu)
end

function optionsScene.load()
  Core.Options.setup({
    title = "Options",
    x = 80,
    y = 80,
    w = 700,
    rowH = 40,
    rowSpacing = 8,
    dropdownMaxVisible = 7,
    back = goBackToMenu,
  })

  Core.Options.newVolume("master_volume", "Volume général")
  Core.Options.newFullscreen("fullscreen", "Plein écran")
  Core.Options.newLetterbox("letterbox", "Bandes noires")
  Core.Options.newAspectFormat("aspect_format", "Format")
  Core.Options.newResolution("resolution", "Résolution")
  Core.Options.newKeyboardLayout("keyboard_layout", "Clavier")

  Core.Options.newInput("validate", "Input : Valider")
  Core.Options.newInput("cancel", "Input : Annuler / Retour")
  Core.Options.newInput("up", "Input : Haut")
  Core.Options.newInput("down", "Input : Bas")
  Core.Options.newInput("left", "Input : Gauche")
  Core.Options.newInput("right", "Input : Droite")
  Core.Options.newInput("attack", "Input : Attaque")

  Core.Options.newAction("reset_inputs", "Réinitialiser les inputs", function()
    Core.Input.resetBindings()
  end)

  Core.Options.newAction("back", "Retour", goBackToMenu)

  Core.Options.build()
end

function optionsScene.enter()
  Core.Options.show()
end

function optionsScene.leave()
  Core.Options.hide()
end

function optionsScene.update(dt)
  Core.Options.update(dt)
end

function optionsScene.draw()
  Core.Options.draw()
end

function optionsScene.mousepressed(x, y, button, istouch, presses)
  Core.Options.mousepressed(x, y, button, istouch, presses)
end

function optionsScene.keypressed(key, scancode, isrepeat)
  Core.Options.keypressed(key, scancode, isrepeat)
end

function optionsScene.gamepadpressed(joystick, button)
  Core.Options.gamepadpressed(joystick, button)
end

function optionsScene.gamepadaxis(joystick, axis, value)
  Core.Options.gamepadaxis(joystick, axis, value)
end

return optionsScene
```

## Initialiser

```lua
Core.Options.setup({
  title = "Options",
  x = 80,
  y = 80,
  w = 700,
  rowH = 40,
  rowSpacing = 8,
  dropdownMaxVisible = 7,
  back = function()
    Core.Scene.set(Menu)
  end,
})
```

## Types d’options

### Toggle

```lua
Core.Options.newToggle("debug", "Debug", false, function(value)
  print("Debug:", value)
end)
```

### Slider

```lua
Core.Options.newSlider("music", "Musique", 0.8, 0, 1, 0.05, function(value)
  print("Volume musique:", value)
end, true)
```

### Choice / dropdown

```lua
Core.Options.newChoice("difficulty", "Difficulté", {
  { label = "Facile", value = "easy" },
  { label = "Normal", value = "normal" },
  { label = "Difficile", value = "hard" },
}, 2, function(value)
  print("Difficulté:", value)
end)
```

### Helpers intégrés

```lua
Core.Options.newVolume("master_volume", "Volume général")
Core.Options.newFullscreen("fullscreen", "Plein écran")
Core.Options.newLetterbox("letterbox", "Bandes noires")
Core.Options.newAspectFormat("aspect_format", "Format")
Core.Options.newResolution("resolution", "Résolution")
Core.Options.newKeyboardLayout("keyboard_layout", "Clavier")
Core.Options.newInput("attack", "Input : Attaque")
Core.Options.newAction("back", "Retour", callback)
```

## Résolution

`newResolution` récupère les modes disponibles avec :

```lua
love.window.getFullscreenModes()
```

Le moteur ajoute aussi la résolution du bureau si nécessaire.

## Contrôles

```txt
Haut / Bas       naviguer
Gauche / Droite  ajuster
Entrée / A       ouvrir / valider
Echap / B        retour / annuler
Souris           clic, hover, drag slider
```

## Sliders

Les sliders supportent :

```txt
- gauche / droite ;
- clic souris ;
- glissé souris.
```

## Dropdowns

```txt
Entrée / A       ouvrir
Haut / Bas       choisir
Entrée / A       appliquer
Echap / B        fermer
```

## API utile

```lua
Core.Options.build()
Core.Options.show()
Core.Options.hide()
Core.Options.update(dt)
Core.Options.draw()
Core.Options.mousepressed(...)
Core.Options.keypressed(...)
Core.Options.gamepadpressed(...)
Core.Options.gamepadaxis(...)
Core.Options.isWaitingForInput()
Core.Options.isDropdownOpen()
Core.Options.getPage()
Core.Options.getGroup()
```
