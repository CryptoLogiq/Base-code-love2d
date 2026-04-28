local sprite = {}

local function resolveImage(imageOrPath, settings)
  if type(imageOrPath) == "string" and Core and Core.Assets and Core.Assets.newImage then
    return Core.Assets.newImage(imageOrPath, settings)
  end

  return imageOrPath
end

local function newQuad(image, x, y, w, h)
  return love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
end

local Sprite = {}
Sprite.__index = Sprite

function Sprite:update(dt)
end

function Sprite:draw(x, y, rotation, sx, sy, ox, oy)
  if not self.image then
    return false
  end

  x = x or self.x or 0
  y = y or self.y or 0
  rotation = rotation or self.rotation or 0
  sx = sx or self.sx or 1
  sy = sy or self.sy or sx
  ox = ox or self.ox or 0
  oy = oy or self.oy or 0

  if self.quad then
    love.graphics.draw(self.image, self.quad, x, y, rotation, sx, sy, ox, oy)
  else
    love.graphics.draw(self.image, x, y, rotation, sx, sy, ox, oy)
  end

  return true
end

function Sprite:setQuad(quad)
  self.quad = quad
  return self
end

function Sprite:setOrigin(ox, oy)
  self.ox = ox or 0
  self.oy = oy or 0
  return self
end

function Sprite:centerOrigin(w, h)
  if self.quad and w and h then
    self.ox = w / 2
    self.oy = h / 2
  elseif self.image then
    self.ox = self.image:getWidth() / 2
    self.oy = self.image:getHeight() / 2
  end

  return self
end

function sprite.newSprite(imageOrPath, config)
  config = config or {}
  local image = resolveImage(imageOrPath, config)

  local new = setmetatable({
    image = image,
    quad = config.quad,
    x = config.x or 0,
    y = config.y or 0,
    rotation = config.rotation or 0,
    sx = config.sx or config.scale or 1,
    sy = config.sy or config.scale or 1,
    ox = config.ox or 0,
    oy = config.oy or 0,
  }, Sprite)

  if config.centerOrigin then
    new:centerOrigin(config.frameW, config.frameH)
  end

  return new
end

local Sheet = {}
Sheet.__index = Sheet

function Sheet:rebuild(config)
  config = config or {}

  if not self.image then
    return self
  end

  self.frameW = config.frameW or self.frameW
  self.frameH = config.frameH or self.frameH
  self.marginX = config.marginX or config.margin or self.marginX or 0
  self.marginY = config.marginY or config.margin or self.marginY or 0
  self.spacingX = config.spacingX or config.spacing or self.spacingX or 0
  self.spacingY = config.spacingY or config.spacing or self.spacingY or 0
  self.offsetX = config.offsetX or self.offsetX or 0
  self.offsetY = config.offsetY or self.offsetY or 0

  local imageW = self.image:getWidth()
  local imageH = self.image:getHeight()
  local startX = self.marginX + self.offsetX
  local startY = self.marginY + self.offsetY
  local usableW = imageW - startX - self.marginX
  local usableH = imageH - startY - self.marginY

  self.columns = config.columns or math.max(0, math.floor((usableW + self.spacingX) / (self.frameW + self.spacingX)))
  self.rows = config.rows or math.max(0, math.floor((usableH + self.spacingY) / (self.frameH + self.spacingY)))
  self.quads = {}
  self.frames = {}

  for row = 0, self.rows - 1 do
    for col = 0, self.columns - 1 do
      local x = startX + col * (self.frameW + self.spacingX)
      local y = startY + row * (self.frameH + self.spacingY)

      if x + self.frameW <= imageW and y + self.frameH <= imageH then
        local quad = newQuad(self.image, x, y, self.frameW, self.frameH)
        table.insert(self.quads, quad)
        table.insert(self.frames, {
          quad = quad,
          x = x,
          y = y,
          w = self.frameW,
          h = self.frameH,
          col = col + 1,
          row = row + 1,
        })
      end
    end
  end

  return self
end

function Sheet:get(index)
  return self.quads[index]
end

function Sheet:getQuad(index)
  return self:get(index)
end

function Sheet:getFrame(index)
  return self.frames[index] or self.quads[index]
end

function Sheet:getFrameQuad(index)
  local frame = self.frames[index]
  return frame and frame.quad or self.quads[index]
end

function Sheet:getCount()
  return #self.quads
end

function Sheet:getFrameCount()
  return self:getCount()
end

function Sheet:getConfig()
  return {
    frameW = self.frameW,
    frameH = self.frameH,
    marginX = self.marginX,
    marginY = self.marginY,
    spacingX = self.spacingX,
    spacingY = self.spacingY,
    offsetX = self.offsetX,
    offsetY = self.offsetY,
    columns = self.columns,
    rows = self.rows,
  }
end

function Sheet:newSprite(index, config)
  config = config or {}
  config.quad = self:get(index or 1)
  config.frameW = self.frameW
  config.frameH = self.frameH
  return sprite.newSprite(self.image, config)
end

function sprite.newSpriteSheet(imageOrPath, frameW, frameH, config)
  config = config or {}
  local image = resolveImage(imageOrPath, config)

  if not image then
    return nil
  end

  local sheet = setmetatable({
    image = image,
    frameW = frameW,
    frameH = frameH,
    marginX = config.marginX or config.margin or 0,
    marginY = config.marginY or config.margin or 0,
    spacingX = config.spacingX or config.spacing or 0,
    spacingY = config.spacingY or config.spacing or 0,
    offsetX = config.offsetX or 0,
    offsetY = config.offsetY or 0,
    columns = config.columns,
    rows = config.rows,
    quads = {},
    frames = {},
  }, Sheet)

  return sheet:rebuild(config)
end

local Animation = {}
Animation.__index = Animation

function Animation:update(dt)
  if self.paused or #self.frames <= 0 then
    return self
  end

  self.timer = self.timer + dt

  while self.timer >= self.frameDuration do
    self.timer = self.timer - self.frameDuration
    self.index = self.index + 1

    if self.index > #self.frames then
      if self.loop then
        self.index = 1
      else
        self.index = #self.frames
        self.paused = true
        break
      end
    end
  end

  self.quad = self.frames[self.index]
  return self
end

function Animation:play()
  self.paused = false
  return self
end

function Animation:pause()
  self.paused = true
  return self
end

function Animation:reset()
  self.index = 1
  self.timer = 0
  self.quad = self.frames[self.index]
  self.paused = false
  return self
end

function sprite.newAnimation(sheet, frameIndexes, fps, config)
  config = config or {}
  local frames = {}

  for _, index in ipairs(frameIndexes or {}) do
    table.insert(frames, sheet:get(index))
  end

  return setmetatable({
    image = sheet.image,
    frames = frames,
    quad = frames[1],
    index = 1,
    timer = 0,
    frameDuration = 1 / (fps or 8),
    loop = config.loop ~= false,
    paused = config.paused == true,
    x = config.x or 0,
    y = config.y or 0,
    rotation = config.rotation or 0,
    sx = config.sx or config.scale or 1,
    sy = config.sy or config.scale or 1,
    ox = config.ox or 0,
    oy = config.oy or 0,
  }, setmetatable(Animation, { __index = Sprite }))
end

function sprite.newAnimations(sheet, definitions)
  local animations = {}

  for name, definition in pairs(definitions or {}) do
    animations[name] = sprite.newAnimation(
      sheet,
      definition.frames or {},
      definition.fps or 8,
      {
        loop = definition.loop ~= false,
        paused = definition.paused == true,
        scale = definition.scale,
        sx = definition.sx,
        sy = definition.sy,
        ox = definition.ox,
        oy = definition.oy,
      }
    )
  end

  return animations
end

function sprite.newAnimationsFromFile(path)
  if not love.filesystem.getInfo(path) then
    return nil
  end

  local chunk = love.filesystem.load(path)
  local data = chunk and chunk()

  if type(data) ~= "table" then
    return nil
  end

  local sheet = sprite.newSpriteSheet(data.image, data.frameW, data.frameH, data)

  if not sheet then
    return nil
  end

  return sprite.newAnimations(sheet, data.animations), sheet, data
end

return sprite
