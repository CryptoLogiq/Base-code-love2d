local Core = {}

local warnedDrawColors = {}

local function isWhiteColor(r, g, b, a)
  local epsilon = 0.001
  return math.abs((r or 1) - 1) <= epsilon
    and math.abs((g or 1) - 1) <= epsilon
    and math.abs((b or 1) - 1) <= epsilon
    and math.abs((a or 1) - 1) <= epsilon
end

local function warnDrawColor(label, r, g, b, a)
  if warnedDrawColors[label] then
    return
  end

  warnedDrawColors[label] = true
  print(string.format(
    "[Core.draw] Attention: %s a laisse love.graphics.setColor(%.2f, %.2f, %.2f, %.2f) actif. Le Core remet en blanc, mais pense a finir ton draw avec love.graphics.setColor(1, 1, 1, 1).",
    label,
    r or 1,
    g or 1,
    b or 1,
    a or 1
  ))
end

local function drawWithWhiteGuard(label, draw)
  love.graphics.setColor(1, 1, 1, 1)
  draw()

  local r, g, b, a = love.graphics.getColor()
  if not isWhiteColor(r, g, b, a) then
    warnDrawColor(label, r, g, b, a)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

Core.render = {
  virtualW = 1280,
  virtualH = 720,
  scaleX = 1,
  scaleY = 1,
  offsetX = 0,
  offsetY = 0,
  viewportW = 1280,
  viewportH = 720,
  enabled = true,
  letterbox = true,
}

function Core.setDimensions(w, h)
  Core.render.virtualW = w or Core.render.virtualW
  Core.render.virtualH = h or Core.render.virtualH
end

function Core.setScaledDrawEnabled(enabled)
  Core.render.enabled = enabled ~= false
end

function Core.setLetterbox(enabled)
  Core.render.letterbox = enabled ~= false
end

function Core.getLetterbox()
  return Core.render.letterbox ~= false
end

function Core.updateRenderScale()
  if not love or not love.graphics or not love.graphics.getDimensions then
    Core.render.scaleX = 1
    Core.render.scaleY = 1
    Core.render.offsetX = 0
    Core.render.offsetY = 0
    Core.render.viewportW = Core.render.virtualW
    Core.render.viewportH = Core.render.virtualH
    return Core.render.scaleX, Core.render.scaleY
  end

  local w, h = love.graphics.getDimensions()

  if Core.render.letterbox ~= false then
    local scale = math.min(w / Core.render.virtualW, h / Core.render.virtualH)

    Core.render.scaleX = scale
    Core.render.scaleY = scale
    Core.render.viewportW = Core.render.virtualW * scale
    Core.render.viewportH = Core.render.virtualH * scale
    Core.render.offsetX = math.floor((w - Core.render.viewportW) / 2 + 0.5)
    Core.render.offsetY = math.floor((h - Core.render.viewportH) / 2 + 0.5)
  else
    Core.render.scaleX = w / Core.render.virtualW
    Core.render.scaleY = h / Core.render.virtualH
    Core.render.offsetX = 0
    Core.render.offsetY = 0
    Core.render.viewportW = w
    Core.render.viewportH = h
  end

  return Core.render.scaleX, Core.render.scaleY
end

function Core.getDimensions()
  return Core.render.virtualW, Core.render.virtualH
end

function Core.toVirtual(x, y)
  if Core.render.enabled == false then
    return x, y
  end

  Core.updateRenderScale()
  return (x - Core.render.offsetX) / Core.render.scaleX, (y - Core.render.offsetY) / Core.render.scaleY
end

function Core.toVirtualDelta(dx, dy)
  if Core.render.enabled == false then
    return dx, dy
  end

  Core.updateRenderScale()
  return dx / Core.render.scaleX, dy / Core.render.scaleY
end

function Core.push()
  if Core.render.enabled == false then
    return
  end

  Core.updateRenderScale()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.push()
  love.graphics.translate(Core.render.offsetX, Core.render.offsetY)
  love.graphics.scale(Core.render.scaleX, Core.render.scaleY)
end

function Core.pop()
  if Core.render.enabled == false then
    return
  end

  love.graphics.pop()
end

function Core.load()
  Core.updateRenderScale()
  Core.Input.load()

  if Core.Options and Core.Options.loadSettings then
    Core.Options.loadSettings()
  end

  if Core.Mouse and Core.Mouse.load then
    Core.Mouse.load()
  end

  if Core.Gui and Core.Gui.load then
    Core.Gui.load()
  end

  if Core.Scene.load then
    Core.Scene.load()
  end
end

function Core.update(dt)
  Core.Input.update(dt)

  if Core.Gui and Core.Gui.update then
    Core.Gui.update(dt)
  end

  if Core.Mouse.update then
    Core.Mouse.update(dt)
  end

  if Core.Scene.update then
    Core.Scene.update(dt)
  end

  Core.Input.clearFrame()
end

function Core.draw()
  if Core.Scene and Core.Scene.syncBackgroundColor then
    Core.Scene.syncBackgroundColor()
  end

  Core.push()

  if Core.Gui and Core.Gui.draw then
    drawWithWhiteGuard("Core.Gui.draw", Core.Gui.draw)
  end

  if Core.Scene.draw then
    drawWithWhiteGuard("Core.Scene.draw", Core.Scene.draw)
  end

  if Core.Mouse.draw then
    drawWithWhiteGuard("Core.Mouse.draw", Core.Mouse.draw)
  end

  Core.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

function Core.keypressed(key, scancode, isrepeat)
  if Core.Gui and Core.Gui.setInputMode then
    Core.Gui.setInputMode("keyboard", true)
  end

  Core.Input.keypressed(key, scancode, isrepeat)

  if Core.Scene.keypressed then
    Core.Scene.keypressed(key, scancode, isrepeat)
  end
end

function Core.keyreleased(key, scancode)
  Core.Input.keyreleased(key, scancode)

  if Core.Scene.keyreleased then
    Core.Scene.keyreleased(key, scancode)
  end
end

function Core.mousepressed(x, y, button, istouch, presses)
  if Core.Gui and Core.Gui.setInputMode then
    Core.Gui.setInputMode("mouse", true)
  end

  local vx, vy = Core.toVirtual(x, y)

  if Core.Mouse and Core.Mouse.mousepressed then
    Core.Mouse.mousepressed(vx, vy, button, istouch, presses)
  end

  Core.Input.mousepressed(vx, vy, button, istouch, presses)

  if Core.Scene.mousepressed then
    Core.Scene.mousepressed(vx, vy, button, istouch, presses)
  end
end

function Core.mousereleased(x, y, button, istouch, presses)
  if Core.Gui and Core.Gui.setInputMode then
    Core.Gui.setInputMode("mouse", true)
  end

  local vx, vy = Core.toVirtual(x, y)

  if Core.Mouse and Core.Mouse.mousereleased then
    Core.Mouse.mousereleased(vx, vy, button, istouch, presses)
  end

  Core.Input.mousereleased(vx, vy, button, istouch, presses)

  if Core.Scene.mousereleased then
    Core.Scene.mousereleased(vx, vy, button, istouch, presses)
  end
end

function Core.mousemoved(x, y, dx, dy, istouch)
  if Core.Gui and Core.Gui.setInputMode then
    Core.Gui.setInputMode("mouse")
  end

  local vx, vy = Core.toVirtual(x, y)
  local vdx, vdy = Core.toVirtualDelta(dx, dy)

  if Core.Mouse and Core.Mouse.mousemoved then
    Core.Mouse.mousemoved(vx, vy, vdx, vdy, istouch)
  end

  if Core.Scene.mousemoved then
    Core.Scene.mousemoved(vx, vy, vdx, vdy, istouch)
  end
end

function Core.gamepadpressed(joystick, button)
  if Core.Gui and Core.Gui.setInputMode then
    Core.Gui.setInputMode("gamepad", true)
  end

  Core.Input.gamepadpressed(joystick, button)

  if Core.Scene.gamepadpressed then
    Core.Scene.gamepadpressed(joystick, button)
  end
end

function Core.gamepadreleased(joystick, button)
  Core.Input.gamepadreleased(joystick, button)

  if Core.Scene.gamepadreleased then
    Core.Scene.gamepadreleased(joystick, button)
  end
end

function Core.gamepadaxis(joystick, axis, value)
  if Core.Gui and Core.Gui.setInputMode and math.abs(value or 0) > (Core.Input.deadzone or 0.25) then
    Core.Gui.setInputMode("gamepad")
  end

  Core.Input.gamepadaxis(joystick, axis, value)

  if Core.Scene.gamepadaxis then
    Core.Scene.gamepadaxis(joystick, axis, value)
  end
end

function Core.joystickadded(joystick)
  Core.Input.joystickadded(joystick)

  if Core.Scene.joystickadded then
    Core.Scene.joystickadded(joystick)
  end
end

function Core.joystickremoved(joystick)
  Core.Input.joystickremoved(joystick)

  if Core.Scene.joystickremoved then
    Core.Scene.joystickremoved(joystick)
  end
end

return Core
