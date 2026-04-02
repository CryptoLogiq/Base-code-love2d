
local menu = Scene.new("Menu")

--
local nav = {}
nav.group = Gui.button.newGroup("Menu")
nav.main = Gui.button.new("Play", 150, 200, 500, 50, "Menu", function(self) Scene.setScene(Game) end)
nav.quit = Gui.button.new("Quit", 150, 500, 500, 50, "Menu", function(self) love.event.quit() end)
--

--
menu.current = nav.main
--

function menu.load()
  nav.group:load()
end
--

function menu.update(dt)
  local current_button = nav.group:update(dt)
  if current_button then
    menu.current = current_button
  end
end
--

function menu.draw()
  nav.group:draw()

  if menu.current then
    -- polish visual current button il selected :
    local bt = menu.current
    love.graphics.setColor(0,1,0,1)
    love.graphics.rectangle("line", bt.x,bt.y,bt.w,bt.h, bt.rounded)
    love.graphics.setColor(1,1,1,1)
  end
end
--

function menu.mousepressed(x,y,button,istouch,presses)
  nav.group:mousepressed(x,y,button,istouch,presses)
end
--

function menu.keypressed(k,s,isrepeat)
  nav.group:keypressed(k,s,isrepeat)
end
--

return menu