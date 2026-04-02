-- Core
require("init")

function love.load()
  Scene.load()
end
--

function love.update(dt)
  Scene.update(dt)
end
--

function love.draw()
  Scene.draw()
end
--

function love.mousepressed(x, y, button, istouch, presses)
  Scene.mousepressed(x, y, button, istouch, presses)
end
--

function love.keypressed(k, s, isrepeat)
  Scene.keypressed(k, s, isrepeat)
end
--