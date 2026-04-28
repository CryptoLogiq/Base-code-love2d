local optionsScene = Core.Scene.New("Options")

local function goBackToMenu()
  Core.Scene.SetScene(Menu)
end

function optionsScene.load()
  Core.Options.setup({
    title = "Options",
    x = 150,
    y = 80,
    w = 620,
    rowH = 34,
    rowSpacing = 6,
    back = goBackToMenu,
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

  Core.Options.addAction("reset_inputs", "Réinitialiser les inputs", function()
    Core.Input.resetBindings()
  end)

  Core.Options.addAction("back", "Retour", goBackToMenu)

  Core.Options.build()
end

function optionsScene.enter(previousScene)
  Core.Options.show()
end

function optionsScene.leave(nextScene)
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
