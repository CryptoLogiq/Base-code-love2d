local coreinput = {}

-- =========================================================
-- CONFIG
-- =========================================================

coreinput.deadzone = 0.25

-- Convention des bindings :
--
-- key:xxx       -> clavier
-- mouse:1       -> clic gauche
-- mouse:2       -> clic droit
-- pad:a         -> bouton manette standard LÖVE
-- axis:leftx+   -> stick gauche vers la droite
-- axis:leftx-   -> stick gauche vers la gauche
-- axis:lefty+   -> stick gauche vers le bas
-- axis:lefty-   -> stick gauche vers le haut

coreinput.map = {
  validate = {
    "key:return",
    "key:space",
    "pad:a",
  },

  cancel = {
    "key:escape",
    "pad:b",
  },

  up = {
    "key:up",
    "key:z",
    "pad:dpup",
    "axis:lefty-",
  },

  down = {
    "key:down",
    "key:s",
    "pad:dpdown",
    "axis:lefty+",
  },

  left = {
    "key:left",
    "key:q",
    "pad:dpleft",
    "axis:leftx-",
  },

  right = {
    "key:right",
    "key:d",
    "pad:dpright",
    "axis:leftx+",
  },

  attack = {
    "key:x",
    "mouse:1",
    "pad:x",
    "pad:rightshoulder",
  },
}

-- =========================================================
-- INTERNAL STATE
-- =========================================================

local rawDown = {}
local rawPressed = {}
local rawReleased = {}

local actionDown = {}
local actionPressed = {}
local actionReleased = {}

local primaryJoystick = nil

-- =========================================================
-- INTERNAL HELPERS
-- =========================================================

local function setRawState(token, isDown)
  if isDown then
    if not rawDown[token] then
      rawPressed[token] = true
    end

    rawDown[token] = true
  else
    if rawDown[token] then
      rawReleased[token] = true
    end

    rawDown[token] = nil
  end
end

local function isPrimaryJoystick(joystick)
  if not joystick then
    return false
  end

  if not primaryJoystick then
    primaryJoystick = joystick
    return true
  end

  return joystick == primaryJoystick
end

local function clearPadStates()
  for token, _ in pairs(rawDown) do
    if token:sub(1, 4) == "pad:" or token:sub(1, 5) == "axis:" then
      rawDown[token] = nil
    end
  end

  for token, _ in pairs(rawPressed) do
    if token:sub(1, 4) == "pad:" or token:sub(1, 5) == "axis:" then
      rawPressed[token] = nil
    end
  end

  for token, _ in pairs(rawReleased) do
    if token:sub(1, 4) == "pad:" or token:sub(1, 5) == "axis:" then
      rawReleased[token] = nil
    end
  end
end

local function updateAxisToken(axis, value)
  local positiveToken = "axis:" .. axis .. "+"
  local negativeToken = "axis:" .. axis .. "-"

  if value > coreinput.deadzone then
    setRawState(positiveToken, true)
    setRawState(negativeToken, false)
  elseif value < -coreinput.deadzone then
    setRawState(negativeToken, true)
    setRawState(positiveToken, false)
  else
    setRawState(positiveToken, false)
    setRawState(negativeToken, false)
  end
end

-- =========================================================
-- LOAD / UPDATE
-- =========================================================

function coreinput.load()
  local joysticks = love.joystick.getJoysticks()

  for _, joystick in ipairs(joysticks) do
    if joystick:isGamepad() then
      primaryJoystick = joystick
      break
    end
  end
end

function coreinput.update(dt)
  actionDown = {}
  actionPressed = {}
  actionReleased = {}

  for action, bindings in pairs(coreinput.map) do
    local isDown = false
    local isPressed = false
    local isReleased = false

    for _, token in ipairs(bindings) do
      if rawDown[token] then
        isDown = true
      end

      if rawPressed[token] then
        isPressed = true
      end

      if rawReleased[token] then
        isReleased = true
      end
    end

    actionDown[action] = isDown
    actionPressed[action] = isPressed

    -- Une action est considérée released seulement si aucun binding
    -- de cette action n'est encore maintenu.
    actionReleased[action] = isReleased and not isDown
  end
end

function coreinput.clearFrame()
  rawPressed = {}
  rawReleased = {}

  actionPressed = {}
  actionReleased = {}
end

-- =========================================================
-- PUBLIC API
-- =========================================================

function coreinput.down(action)
  return actionDown[action] == true
end

function coreinput.pressed(action)
  return actionPressed[action] == true
end

function coreinput.released(action)
  return actionReleased[action] == true
end

-- Compatibilité avec ton ancien nommage
function coreinput.isDown(action)
  return coreinput.down(action)
end

function coreinput.isPressed(action)
  return coreinput.pressed(action)
end

function coreinput.isReleased(action)
  return coreinput.released(action)
end

function coreinput.getAxis(axis)
  if axis == "horizontal" then
    local left = coreinput.down("left")
    local right = coreinput.down("right")

    if left and not right then
      return -1
    elseif right and not left then
      return 1
    end

  elseif axis == "vertical" then
    local up = coreinput.down("up")
    local down = coreinput.down("down")

    if up and not down then
      return -1
    elseif down and not up then
      return 1
    end
  end

  return 0
end

function coreinput.bind(action, token)
  if not coreinput.map[action] then
    coreinput.map[action] = {}
  end

  table.insert(coreinput.map[action], token)
end

function coreinput.unbind(action)
  coreinput.map[action] = {}
end

function coreinput.setDeadzone(value)
  coreinput.deadzone = value or 0.25
end

-- =========================================================
-- KEYBOARD EVENTS
-- =========================================================

function coreinput.keypressed(key, scancode, isrepeat)
  if isrepeat then
    return
  end

  setRawState("key:" .. key, true)
end

function coreinput.keyreleased(key, scancode)
  setRawState("key:" .. key, false)
end

-- =========================================================
-- MOUSE EVENTS
-- =========================================================

function coreinput.mousepressed(x, y, button, istouch, presses)
  setRawState("mouse:" .. tostring(button), true)
end

function coreinput.mousereleased(x, y, button, istouch, presses)
  setRawState("mouse:" .. tostring(button), false)
end

-- =========================================================
-- GAMEPAD EVENTS
-- =========================================================

function coreinput.gamepadpressed(joystick, button)
  if not isPrimaryJoystick(joystick) then
    return
  end

  setRawState("pad:" .. button, true)
end

function coreinput.gamepadreleased(joystick, button)
  if not isPrimaryJoystick(joystick) then
    return
  end

  setRawState("pad:" .. button, false)
end

function coreinput.gamepadaxis(joystick, axis, value)
  if not isPrimaryJoystick(joystick) then
    return
  end

  updateAxisToken(axis, value)
end

function coreinput.joystickadded(joystick)
  if not primaryJoystick and joystick:isGamepad() then
    primaryJoystick = joystick
  end
end

function coreinput.joystickremoved(joystick)
  if joystick == primaryJoystick then
    primaryJoystick = nil
    clearPadStates()

    local joysticks = love.joystick.getJoysticks()

    for _, otherJoystick in ipairs(joysticks) do
      if otherJoystick:isGamepad() then
        primaryJoystick = otherJoystick
        break
      end
    end
  end
end

function coreinput.getJoystick()
  return primaryJoystick
end

return coreinput