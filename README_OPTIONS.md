# Core.Options

`Core.Options` construit un menu d'options fonctionnel à partir d'une petite API.

## Exemple minimal

```lua
Core.Options.setup({
  title = "Options",
  x = 150,
  y = 80,
  w = 620,
  rowH = 34,
  rowSpacing = 6,
  back = function()
    Core.Scene.SetScene(Menu)
  end,
})

Core.Options.addVolume("master_volume", "Volume général")
Core.Options.addFullscreen("fullscreen", "Plein écran")
Core.Options.addResolution("resolution", "Résolution")

Core.Options.addInput("validate", "Input : Valider")
Core.Options.addInput("cancel", "Input : Annuler / Retour")
Core.Options.addInput("up", "Input : Haut")
Core.Options.addInput("down", "Input : Bas")
Core.Options.addInput("left", "Input : Gauche")
Core.Options.addInput("right", "Input : Droite")
Core.Options.addInput("attack", "Input : Attaque")

Core.Options.addAction("back", "Retour", function()
  Core.Scene.SetScene(Menu)
end)

Core.Options.build()
```

## Utilisation dans une scène

```lua
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
```

## Types d'options

### Booléen

```lua
Core.Options.addBool("fullscreen", "Plein écran", false, function(value)
  love.window.setFullscreen(value)
end)
```

### Slider

```lua
Core.Options.addSlider("volume", "Volume", 1, 0, 1, 0.05, function(value)
  love.audio.setVolume(value)
end, true)
```

Le dernier argument `true` affiche la valeur en pourcentage.

### Choice

```lua
Core.Options.addChoice("difficulty", "Difficulté", {
  { label = "Facile", value = "easy" },
  { label = "Normal", value = "normal" },
  { label = "Difficile", value = "hard" },
}, 2, function(value)
  print("Difficulté :", value)
end)
```

### Input remappable

```lua
Core.Options.addInput("validate", "Input : Valider")
```

Quand l'option est validée, le menu attend une touche clavier, un bouton manette, un axe de stick ou un clic souris.

### Action

```lua
Core.Options.addAction("reset_inputs", "Réinitialiser les inputs", function()
  Core.Input.resetBindings()
end)
```

## Contrôles du menu

```txt
Haut / Bas      : naviguer
Gauche / Droite : modifier une valeur
Entrée / A      : valider
Echap / B       : retour ou annuler un remapping
```

## Notes

- `Core.Options` utilise `Core.Gui.Page` + `Core.Gui.button.newGroup`.
- Le groupe actif est géré par `Core.Gui.setActiveGroup`.
- Les remappings utilisent `Core.Input.setPrimaryBinding(action, token)`.
- Le menu d'exemple est déjà disponible via le bouton `Options` dans `scene_menu.lua`.
