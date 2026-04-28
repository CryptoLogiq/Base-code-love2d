local mouse = {
  x = 0,
  y = 0,
  w = 1,
  h = 1,
  debug = true,
  moveThreshold = 1,
}

function mouse.load()
  local x, y = love.mouse.getPosition()

  if Core and Core.toVirtual then
    x, y = Core.toVirtual(x, y)
  end

  mouse.x, mouse.y = x, y
  mouse.previousX = mouse.x
  mouse.previousY = mouse.y
end

function mouse.update(dt)
  local x, y = love.mouse.getPosition()

  if Core and Core.toVirtual then
    x, y = Core.toVirtual(x, y)
  end

  if mouse.previousX ~= nil and mouse.previousY ~= nil then
    local dx = x - mouse.previousX
    local dy = y - mouse.previousY

    if (math.abs(dx) >= mouse.moveThreshold or math.abs(dy) >= mouse.moveThreshold)
      and Core and Core.Gui and Core.Gui.setInputMode then
      Core.Gui.setInputMode("mouse")
    end
  end

  mouse.x, mouse.y = x, y
  mouse.previousX, mouse.previousY = x, y
end

function mouse.draw()
  if Core and Core.Gui and Core.Gui.isGamepadMode and Core.Gui.isGamepadMode() then
    return
  end

  if mouse.debug then
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.circle("fill", mouse.x, mouse.y, 3)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function mouse.mousepressed(x, y, button, istouch, presses)
  mouse.x, mouse.y = x, y
  mouse.previousX, mouse.previousY = x, y
end

function mouse.mousemoved(x, y, dx, dy, istouch)
  mouse.x, mouse.y = x, y
  mouse.previousX, mouse.previousY = x, y
end

function mouse.mousereleased(x, y, button, istouch, presses)
  mouse.x, mouse.y = x, y
  mouse.previousX, mouse.previousY = x, y
end

return mouse
