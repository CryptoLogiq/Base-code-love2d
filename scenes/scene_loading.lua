local loading = Core.Scene.new("Loading")

local logo = nil
local timer = 0
local minDuration = 3

function loading.load()
  Core.Scene.setBackgroundColor(0, 0, 0, 1, loading)

  logo = Core.Sprite.newSprite("assets/logo.png", {
    centerOrigin = true,
    scale = 0.22,
    filter = { "linear", "linear" },
  })
end

function loading.enter(previousScene)
  timer = 0
end

function loading.update(dt)
  timer = timer + dt

  if timer >= minDuration then
    Core.Scene.set(Menu)
  end
end

function loading.draw()
  local w, h = Core.getDimensions()
  local alpha = math.min(1, timer / 0.35)

  love.graphics.setColor(0.06, 0.07, 0.12, 1)
  love.graphics.rectangle("fill", 0, 0, w, h)

  love.graphics.setColor(1, 1, 1, alpha)

  if logo then
    logo:draw(w / 2, h / 2 - 20)
  end

  love.graphics.setColor(1, 1, 1, alpha)
  love.graphics.printf("Base Code Love2D", 0, h / 2 + 128, w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

function loading.keypressed(key, scancode, isrepeat)
  if not isrepeat then
    Core.Scene.set(Menu)
  end
end

function loading.mousepressed(x, y, button, istouch, presses)
  Core.Scene.set(Menu)
end

return loading
