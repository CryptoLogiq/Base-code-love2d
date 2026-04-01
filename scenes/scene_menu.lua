
local menu = Scene.new("Menu")

local nav = {
  main={name="main"},
  quit={name="quit game", txt="Press Enter to Exit Game or Escape to Abort."}
}
menu.current = nav.main
--

function menu.load()
  menu.current = nav.main
end
--

function menu.update(dt)
end
--

function menu.draw()
  if menu.current == nav.quit then
    love.graphics.printf(nav.quit.txt,0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center",0,2,2,love.graphics.getWidth()/4)
  end
end
--

function menu.mousepressed(x,y,button,istouch,presses)
end
--

function menu.keypressed(k,s,isrepeat)
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