local game = Core.Scene.New("Game")

local player = {
  x = 100,
  y = 100,
  speed = 180,
}

function game.load()
end

function game.update(dt)
  local xAxis = Core.Input.getAxis("horizontal")
  local yAxis = Core.Input.getAxis("vertical")

  player.x = player.x + xAxis * player.speed * dt
  player.y = player.y + yAxis * player.speed * dt

  if Core.Input.pressed("attack") then
    print("ATTACK")
  end

  if Core.Input.pressed("cancel") then
    Core.Scene.SetScene(Menu)
  end
end

function game.draw()
  love.graphics.circle("fill", player.x, player.y, 20)
end

return game