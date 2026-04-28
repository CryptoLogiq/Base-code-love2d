local menu = Core.Scene.new("Menu")

local nav = {}

menu.page = Core.Gui.newPage("MenuPage")

nav.group = Core.Gui.newButtonGroup("Menu", {
  direction = "vertical",
  x = "center",
  y = 190,
  w = 500,
  h = 50,
  areaH = 360,
  spacing = "auto",
})
menu.page:addGroup("main", nav.group)

nav.play = Core.Gui.newButton("Play", 0, 0, 500, 50, nav.group, function(self)
  Core.Scene.set(Game)
end)

nav.options = Core.Gui.newButton("Options", 0, 0, 500, 50, nav.group, function(self)
  Core.Scene.set(Options)
end)

nav.spritesheet = Core.Gui.newButton("SpriteSheet", 0, 0, 500, 50, nav.group, function(self)
  Core.Scene.set(SpriteSheet)
end)

nav.credits = Core.Gui.newButton("Credits", 0, 0, 500, 50, nav.group, function(self)
  print("Credits menu is not implemented yet.")
end)
nav.credits:setVisible(false)

nav.quit = Core.Gui.newButton("Quit", 0, 0, 500, 50, nav.group, function(self)
  love.event.quit()
end)

function menu.setCreditsUnlocked(unlocked)
  nav.credits:setVisible(unlocked == true)
end

function menu.load()
  nav.group:load()
  nav.group:selectIndex(1)
end

function menu.enter(previousScene)
  menu.page:show()
  menu.page:setActiveGroup("main")
end

function menu.leave(nextScene)
  menu.page:hide()
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
