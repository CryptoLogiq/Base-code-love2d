local gui = {
  activeGroup = nil,

  -- Dernier peripherique qui pilote le feedback visuel de l'UI.
  -- mouse    : le hover souris a la priorite.
  -- keyboard : la selection du groupe actif a la priorite.
  -- gamepad  : la selection du groupe actif a la priorite.
  inputMode = "keyboard",
  previousInputMode = nil,

  -- Petit delai anti-flicker entre deux familles de peripheriques.
  -- Les evenements forts comme clic souris / touche clavier / bouton manette
  -- peuvent forcer le changement immediatement.
  inputModeDelay = 0.20,
  inputModeTimer = 0,
}

local f = "core/gui/gui_"

gui.button = require(f .. "button")
gui.page = require(f .. "page")

-- Aliases plus lisibles pour l'utilisation cote scenes.
gui.Button = gui.button
gui.Page = gui.page
gui.Panel = gui.page

function gui.newButton(...)
  return gui.button.new(...)
end

function gui.newButtonGroup(...)
  return gui.button.newGroup(...)
end

function gui.newPage(...)
  return gui.page.new(...)
end

gui.newPanel = gui.newPage

-- =========================================================
-- INPUT MODE / DEVICE PRIORITY
-- =========================================================

local function syncMouseVisibility()
  if love and love.mouse and love.mouse.setVisible then
    love.mouse.setVisible(gui.inputMode ~= "gamepad")
  end
end

function gui.setInputMode(mode, force)
  if mode ~= "mouse" and mode ~= "keyboard" and mode ~= "gamepad" then
    return false
  end

  if gui.inputMode == mode then
    gui.inputModeTimer = gui.inputModeDelay
    syncMouseVisibility()
    return true
  end

  -- Evite les allers-retours visuels trop rapides entre souris et clavier/manette.
  -- Exemple : la souris reste posee sur un bouton pendant qu'on navigue a la manette.
  if gui.inputModeTimer > 0 and not force then
    return false
  end

  gui.previousInputMode = gui.inputMode
  gui.inputMode = mode
  gui.inputModeTimer = gui.inputModeDelay
  syncMouseVisibility()
  return true
end

function gui.getInputMode()
  return gui.inputMode
end

function gui.isMouseMode()
  return gui.inputMode == "mouse"
end

function gui.isKeyboardMode()
  return gui.inputMode == "keyboard"
end

function gui.isGamepadMode()
  return gui.inputMode == "gamepad"
end

function gui.isNavigationMode()
  return gui.inputMode == "keyboard" or gui.inputMode == "gamepad"
end

function gui.setInputModeDelay(delay)
  gui.inputModeDelay = delay or 0.20
  return gui.inputModeDelay
end

-- =========================================================
-- ACTIVE GROUP
-- =========================================================

function gui.setActiveGroup(group)
  if gui.activeGroup == group then
    if group then
      group.active = true

      if group.selectFirstAvailable and not group.current then
        group:selectFirstAvailable()
      elseif group.selectIndex and not group.current and #group > 0 then
        group:selectIndex(group.selectedIndex or 1)
      end
    end

    return group
  end

  if gui.activeGroup then
    gui.activeGroup.active = false
  end

  gui.activeGroup = group

  if group then
    group.active = true

    if group.selectFirstAvailable and not group.current then
      group:selectFirstAvailable()
    elseif group.selectIndex and not group.current and #group > 0 then
      group:selectIndex(group.selectedIndex or 1)
    end
  end

  return group
end

function gui.getActiveGroup()
  return gui.activeGroup
end

function gui.clearActiveGroup(group)
  if not group or gui.activeGroup == group then
    if gui.activeGroup then
      gui.activeGroup.active = false
    end

    gui.activeGroup = nil
  end
end

function gui.load()
  syncMouseVisibility()
end

function gui.update(dt)
  if gui.inputModeTimer > 0 then
    gui.inputModeTimer = math.max(0, gui.inputModeTimer - dt)
  end
end

function gui.draw()
end

function gui.mousepressed(x, y, button, istouch, presses)
end

function gui.keypressed(k, s, isrepeat)
end

return gui
