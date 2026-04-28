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
