-- Core
require("init")

function love.load()
  Core.load()
end
--

function love.update(dt)
  Core.update(dt)
end
--

function love.draw()
  Core.draw()
end
--

function love.mousepressed(x, y, button, istouch, presses)
  Core.mousepressed(x, y, button, istouch, presses)
end
--

function love.keypressed(k, s, isrepeat)
  Core.keypressed(k, s, isrepeat)
end
--