require("init")

function love.load()
  Core.load()
end

function love.update(dt)
  Core.update(dt)
end

function love.draw()
  Core.draw()
end

function love.keypressed(key, scancode, isrepeat)
  Core.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  Core.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
  Core.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
  Core.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
  Core.mousemoved(x, y, dx, dy, istouch)
end

function love.gamepadpressed(joystick, button)
  Core.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
  Core.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
  Core.gamepadaxis(joystick, axis, value)
end

function love.joystickadded(joystick)
  Core.joystickadded(joystick)
end

function love.joystickremoved(joystick)
  Core.joystickremoved(joystick)
end
