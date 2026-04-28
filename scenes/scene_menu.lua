local menu = Core.Scene.New("Menu")

local nav = {}

menu.page = Core.Gui.Page.new("MenuPage")

nav.group = Core.Gui.button.newGroup("Menu")
menu.page:addGroup("main", nav.group)

nav.main = Core.Gui.button.new("Play", 150, 200, 500, 50, nav.group, function(self)
  Core.Scene.SetScene(Game)
end)

nav.quit = Core.Gui.button.new("Quit", 150, 500, 500, 50, nav.group, function(self)
  love.event.quit()
end)

function menu.load()
  menu.page:show()
  nav.group:load()
  nav.group:selectIndex(1)
  menu.page:setActiveGroup("main")
end

function menu.update(dt)
  menu.page:update(dt)

  if Core.Input.pressed("cancel") then
    love.event.quit()
  end
end

function menu.draw()
  menu.page:draw()
end

function menu.mousepressed(x, y, button, istouch, presses)
  menu.page:mousepressed(x, y, button, istouch, presses)
end

return menu
