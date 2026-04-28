local game = Core.Scene.new("Game")

local player = {
  x = 100,
  y = 100,
  speed = 180,
  sprite = nil,
  animations = nil,
  currentAnimation = nil,
  actionTimer = 0,
}

function game.load()
  player.animations = Core.Sprite.newAnimationsFromFile("assets/spritesheet_player_clean_animations.lua")

  if player.animations then
    for _, animation in pairs(player.animations) do
      animation.sx = 2
      animation.sy = 2
      animation.ox = 16
      animation.oy = 16
    end

    player.currentAnimation = player.animations.idle
    return
  end

  player.sprite = Core.Sprite.newSprite("assets/player.png", {
    centerOrigin = true,
    scale = 0.10,
    filter = { "nearest", "nearest" },
  })
end

function game.update(dt)
  local xAxis = Core.Input.getAxis("horizontal")
  local yAxis = Core.Input.getAxis("vertical")

  player.x = player.x + xAxis * player.speed * dt
  player.y = player.y + yAxis * player.speed * dt

  if player.animations then
    player.actionTimer = math.max(0, player.actionTimer - dt)

    if player.actionTimer <= 0 then
      if xAxis ~= 0 or yAxis ~= 0 then
        player.currentAnimation = player.animations.walk or player.currentAnimation
      else
        player.currentAnimation = player.animations.idle or player.currentAnimation
      end
    end

    if player.currentAnimation and player.currentAnimation.update then
      player.currentAnimation:update(dt)
    end
  end

  if Core.Input.pressed("attack") then
    print("ATTACK")
    if player.animations and player.animations.attack then
      player.animations.attack:reset()
      player.currentAnimation = player.animations.attack
      player.actionTimer = #player.animations.attack.frames * player.animations.attack.frameDuration
    end
  end

  if Core.Input.pressed("cancel") then
    Core.Scene.set(Menu)
  end
end

function game.draw()
  if player.currentAnimation and player.currentAnimation:draw(player.x, player.y) then
    return
  end

  if player.sprite and player.sprite:draw(player.x, player.y) then
    return
  end

  love.graphics.circle("fill", player.x, player.y, 20)
end

return game
