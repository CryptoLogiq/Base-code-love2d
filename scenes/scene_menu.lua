
local menu = Scene.new("Menu")

--
local nav = {}
nav.group = Gui.button.newGroup("Menu")
print("nav.group : ", nav.group)
nav.main = Gui.button.new("Play", 150, 200, 500, 50, "Menu")
nav.quit = Gui.button.new("Quit", 150, 500, 500, 50, "Menu", function(self) love.event.quit() end)
--

--
menu.current = nav.main

--

function menu.load()
  menu.current = nav.main
  nav.group:load()
end
--

function menu.update(dt)
  nav.group:update(dt)
end
--

function menu.draw()
  if menu.current == nav.quit then
    love.graphics.printf(nav.quit.txt,0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center",0,2,2,love.graphics.getWidth()/4)
  end
  nav.group:draw()
end
--

function menu.mousepressed(x,y,button,istouch,presses)
  nav.group:mousepressed(x,y,button,istouch,presses)
end
--

function menu.keypressed(k,s,isrepeat)
  nav.group:keypressed(k,s,isrepeat)
  --
  if k == "escape" then
    if menu.current == nav.main then
      menu.current = nav.quit
      return
    end
  end
  --
  if menu.current == nav.quit then
    if k == "return" then
      love.event.quit()
      return
    elseif k == "escape" then
      menu.current = nav.main
    end
  end
end
--

return menu