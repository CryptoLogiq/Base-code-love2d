local editor = Core.Scene.new("SpriteSheet")

local settingsPath = "spritesheet_editor.lua"
local exportPath = "spritesheet_player_animations.lua"
local imagePath = "assets/spritesheet_player_work.png"

local state = {
  sheet = nil,
  selected = 1,
  zoom = 3,
  rows = {},
  frameRects = {},
  timelineRects = {},
  buttons = {},
  hoveredFrame = nil,
  hoveredTimeline = nil,
  status = "Selectionne des frames pour construire une animation.",
  animNames = { "idle", "walk", "jump", "attack" },
  currentAnim = 1,
  previewTimer = 0,
  previewIndex = 1,
  playing = true,
  previewScale = 3,
  layout = {
    panelX = 24,
    panelY = 24,
    panelW = 320,
    panelH = 672,
    sheetX = 380,
    sheetY = 54,
    previewX = 990,
    previewY = 78,
    timelineX = 380,
    timelineY = 572,
  },
  animations = {
    idle = { frames = {}, fps = 6, loop = true },
    walk = { frames = {}, fps = 10, loop = true },
    jump = { frames = {}, fps = 8, loop = false },
    attack = { frames = {}, fps = 12, loop = false },
  },
  params = {
    frameW = 32,
    frameH = 32,
    marginX = 13,
    marginY = 9,
    spacingX = 5,
    spacingY = 7,
    offsetX = 0,
    offsetY = 0,
  },
}

local function getCurrentAnimation()
  local name = state.animNames[state.currentAnim]
  return name, state.animations[name]
end

local params = {
  { key = "frameW", label = "Frame W", min = 1 },
  { key = "frameH", label = "Frame H", min = 1 },
  { key = "marginX", label = "Margin X", min = 0 },
  { key = "marginY", label = "Margin Y", min = 0 },
  { key = "spacingX", label = "Spacing X", min = 0 },
  { key = "spacingY", label = "Spacing Y", min = 0 },
  { key = "offsetX", label = "Offset X", min = -512 },
  { key = "offsetY", label = "Offset Y", min = -512 },
}

local function serialize(value, indent)
  indent = indent or ""

  if type(value) == "table" then
    local nextIndent = indent .. "  "
    local lines = {"{"}

    for k, v in pairs(value) do
      local key = type(k) == "string" and k .. " = " or "[" .. tostring(k) .. "] = "
      table.insert(lines, nextIndent .. key .. serialize(v, nextIndent) .. ",")
    end

    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
  end

  if type(value) == "string" then
    return string.format("%q", value)
  end

  return tostring(value)
end

local function readLuaTable(path)
  if not love.filesystem.getInfo(path) then
    return nil
  end

  local chunk = love.filesystem.load(path)
  local data = chunk and chunk()

  if type(data) ~= "table" then
    return nil
  end

  return data
end

local function applyAnimationData(data)
  if type(data) ~= "table" then
    return false
  end

  imagePath = data.imagePath or data.image or imagePath

  local sourceParams = data.params or data

  for _, param in ipairs(params) do
    local value = sourceParams[param.key]

    if type(value) == "number" then
      state.params[param.key] = value
    end
  end

  if type(data.animNames) == "table" then
    state.animNames = data.animNames
  end

  if type(data.animations) == "table" then
    for name, animation in pairs(data.animations) do
      if type(animation) == "table" then
        local exists = false

        for _, animName in ipairs(state.animNames) do
          if animName == name then
            exists = true
            break
          end
        end

        if not exists then
          table.insert(state.animNames, name)
        end

        state.animations[name] = {
          frames = type(animation.frames) == "table" and animation.frames or {},
          fps = type(animation.fps) == "number" and animation.fps or 8,
          loop = animation.loop ~= false,
        }
      end
    end
  end

  return true
end

local function loadSettings()
  local loadedFrom = nil

  if applyAnimationData(readLuaTable(settingsPath)) then
    loadedFrom = settingsPath
  elseif applyAnimationData(readLuaTable(exportPath)) then
    loadedFrom = exportPath
  end

  if loadedFrom then
    state.status = "Projet animation recharge depuis " .. loadedFrom .. "."
  end
end

local function reloadProject()
  loadSettings()
  rebuildSheet()
  state.previewIndex = 1
  state.previewTimer = 0
end

local function saveSettings()
  local data = {
    imagePath = imagePath,
    params = state.params,
    animNames = state.animNames,
    animations = state.animations,
  }

  love.filesystem.write(settingsPath, "return " .. serialize(data) .. "\n")
  print("[SpriteSheet] Reglages sauvegardes dans " .. settingsPath)
  state.status = "Reglages sauvegardes : " .. settingsPath
end

local function exportAnimations()
  local data = {
    image = imagePath,
    frameW = state.params.frameW,
    frameH = state.params.frameH,
    marginX = state.params.marginX,
    marginY = state.params.marginY,
    spacingX = state.params.spacingX,
    spacingY = state.params.spacingY,
    offsetX = state.params.offsetX,
    offsetY = state.params.offsetY,
    animations = state.animations,
  }

  local ok, message = love.filesystem.write(exportPath, "return " .. serialize(data) .. "\n")

  if ok then
    saveSettings()
    print("[SpriteSheet] Animations exportees dans le dossier de sauvegarde Love2D : " .. exportPath)
    state.status = "Export OK : " .. exportPath .. " dans le dossier de sauvegarde Love2D."
  else
    print("[SpriteSheet] Export impossible : " .. tostring(message))
    state.status = "Export impossible : " .. tostring(message)
  end
end

local function rebuildSheet()
  state.sheet = Core.Sprite.newSpriteSheet(imagePath, state.params.frameW, state.params.frameH, state.params)
  state.previewIndex = 1
  state.previewTimer = 0
end

local function changeParam(delta)
  local param = params[state.selected]
  local key = param.key
  local value = (state.params[key] or 0) + delta

  if param.min then
    value = math.max(param.min, value)
  end

  state.params[key] = value
  rebuildSheet()
  state.status = tostring(param.label) .. " = " .. tostring(value)
end

local function addFrameToAnimation(index)
  local name, animation = getCurrentAnimation()

  if not animation then
    return
  end

  table.insert(animation.frames, index)
  state.previewIndex = #animation.frames
  state.previewTimer = 0
  state.status = "Frame " .. tostring(index) .. " ajoutee a " .. tostring(name) .. "."
end

local function removeTimelineFrame(index)
  local name, animation = getCurrentAnimation()

  if not animation or not animation.frames[index] then
    return
  end

  table.remove(animation.frames, index)
  state.previewIndex = math.min(state.previewIndex, math.max(1, #animation.frames))
  state.previewTimer = 0
  state.status = "Frame retiree de " .. tostring(name) .. "."
end

local function clearCurrentAnimation()
  local name, animation = getCurrentAnimation()

  if animation then
    animation.frames = {}
    state.previewIndex = 1
    state.previewTimer = 0
    state.status = "Animation " .. tostring(name) .. " videe."
  end
end

local function changeAnimation(delta)
  state.currentAnim = state.currentAnim + delta

  if state.currentAnim < 1 then
    state.currentAnim = #state.animNames
  elseif state.currentAnim > #state.animNames then
    state.currentAnim = 1
  end

  state.previewIndex = 1
  state.previewTimer = 0
  state.status = "Animation active : " .. tostring(state.animNames[state.currentAnim])
end

local function changeFps(delta)
  local name, animation = getCurrentAnimation()

  if animation then
    animation.fps = math.max(1, math.min(60, (animation.fps or 8) + delta))
    state.status = "FPS " .. tostring(name) .. " : " .. tostring(animation.fps)
  end
end

local function toggleLoop()
  local name, animation = getCurrentAnimation()

  if animation then
    animation.loop = animation.loop ~= true
    state.status = tostring(name) .. " joue en mode " .. (animation.loop and "loop" or "once") .. "."
  end
end

local function drawButton(id, text, x, y, w, h)
  state.buttons[id] = { x = x, y = y, w = w, h = h }
  love.graphics.setColor(0.16, 0.18, 0.22, 1)
  love.graphics.rectangle("fill", x, y, w, h, 4, 4)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(text, x, y + 5, w, "center")
end

local function drawPanel()
  local layout = state.layout

  love.graphics.setColor(0.10, 0.11, 0.14, 0.96)
  love.graphics.rectangle("fill", layout.panelX, layout.panelY, layout.panelW, layout.panelH)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("SpriteSheet", 44, 44)
  love.graphics.print(imagePath, 44, 68)

  local y = 112
  state.rows = {}

  for index, param in ipairs(params) do
    local active = index == state.selected

    if active then
      love.graphics.setColor(0.24, 0.53, 0.74, 1)
      love.graphics.rectangle("fill", 40, y - 6, 218, 26, 4, 4)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(param.label, 48, y)
    love.graphics.printf(tostring(state.params[param.key]), 176, y, 70, "right")

    love.graphics.setColor(0.16, 0.18, 0.22, 1)
    love.graphics.rectangle("fill", 266, y - 7, 26, 26, 4, 4)
    love.graphics.rectangle("fill", 298, y - 7, 26, 26, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("-", 266, y - 2, 26, "center")
    love.graphics.printf("+", 298, y - 2, 26, "center")

    state.rows[index] = {
      y = y - 7,
      h = 26,
      selectX = 40,
      selectW = 218,
      minusX = 266,
      plusX = 298,
      buttonW = 26,
    }

    y = y + 34
  end

  local count = state.sheet and state.sheet:getCount() or 0
  local animName, animation = getCurrentAnimation()

  love.graphics.setColor(0.76, 0.82, 0.88, 1)
  love.graphics.print("Frames detectees: " .. count, 44, 400)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Animation", 44, 438)
  love.graphics.print(animName or "-", 136, 438)
  drawButton("prevAnim", "<", 226, 432, 30, 28)
  drawButton("nextAnim", ">", 262, 432, 30, 28)

  love.graphics.setColor(0.76, 0.82, 0.88, 1)
  love.graphics.print("FPS: " .. tostring(animation and animation.fps or 0), 44, 476)
  drawButton("fpsMinus", "-", 150, 470, 30, 28)
  drawButton("fpsPlus", "+", 186, 470, 30, 28)
  drawButton("loop", animation and animation.loop and "Loop" or "Once", 226, 470, 66, 28)

  drawButton("play", state.playing and "Pause" or "Play", 44, 514, 74, 28)
  drawButton("clear", "Clear", 126, 514, 74, 28)
  drawButton("export", "Export", 208, 514, 80, 28)

  love.graphics.setColor(0.76, 0.82, 0.88, 1)
  love.graphics.print("Frame survolee: " .. tostring(state.hoveredFrame or "-"), 44, 568)
  love.graphics.print("Clic frame: ajouter", 44, 600)
  love.graphics.print("Clic droit timeline: retirer", 44, 624)
  love.graphics.print("S save | E export | R reload | Esc menu", 44, 648)
end

local function pointInRect(x, y, rectX, rectY, rectW, rectH)
  return x >= rectX and x <= rectX + rectW and y >= rectY and y <= rectY + rectH
end

local function drawSheet()
  if not state.sheet or not state.sheet.image then
    love.graphics.setColor(1, 0.35, 0.35, 1)
    love.graphics.print("Impossible de charger " .. imagePath, 310, 60)
    return
  end

  local image = state.sheet.image
  local layout = state.layout
  local x = layout.sheetX
  local y = layout.sheetY
  local zoom = state.zoom
  local animName, animation = getCurrentAnimation()
  local usedFrames = {}

  state.frameRects = {}

  if animation then
    for order, frameIndex in ipairs(animation.frames) do
      usedFrames[frameIndex] = order
    end
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(image, x, y, 0, zoom, zoom)

  love.graphics.setLineWidth(1)

  for index, frame in ipairs(state.sheet.frames) do
    local frameX = x + frame.x * zoom
    local frameY = y + frame.y * zoom
    local frameW = frame.w * zoom
    local frameH = frame.h * zoom

    state.frameRects[index] = { x = frameX, y = frameY, w = frameW, h = frameH }

    if index == state.hoveredFrame then
      love.graphics.setColor(0.20, 1, 0.45, 0.30)
      love.graphics.rectangle("fill", frameX, frameY, frameW, frameH)
      love.graphics.setColor(0.20, 1, 0.45, 1)
    elseif usedFrames[index] then
      love.graphics.setColor(1, 0.82, 0.20, 0.35)
      love.graphics.rectangle("fill", frameX, frameY, frameW, frameH)
      love.graphics.setColor(1, 0.82, 0.20, 1)
    else
      love.graphics.setColor(0.15, 0.80, 1, 0.85)
    end

    love.graphics.rectangle("line", frameX, frameY, frameW, frameH)

    if index <= 99 then
      love.graphics.setColor(0, 0, 0, 0.65)
      love.graphics.rectangle("fill", frameX, frameY, 22, 16)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(tostring(index), frameX + 3, frameY + 1)
    end
  end

  love.graphics.setColor(1, 1, 1, 0.65)
  love.graphics.print(image:getWidth() .. "x" .. image:getHeight() .. " px", x, y + image:getHeight() * zoom + 14)
  love.graphics.setColor(1, 1, 1, 1)
end

local function drawPreview()
  local name, animation = getCurrentAnimation()

  if not state.sheet or not animation then
    return
  end

  local layout = state.layout
  local x = layout.previewX
  local y = layout.previewY
  local frameIndex = animation.frames[state.previewIndex]
  local quad = frameIndex and state.sheet:get(frameIndex)

  love.graphics.setColor(0.10, 0.11, 0.14, 0.96)
  love.graphics.rectangle("fill", x - 20, y - 44, 250, 270)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Preview", x, y - 24)

  love.graphics.setColor(0.05, 0.055, 0.07, 1)
  love.graphics.rectangle("fill", x, y, 160, 150)

  if quad then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(state.sheet.image, quad, x + 80, y + 75, 0, state.previewScale, state.previewScale, state.params.frameW / 2, state.params.frameH / 2)
  end

  love.graphics.setColor(0.76, 0.82, 0.88, 1)
  love.graphics.print("Animation: " .. tostring(name or "-"), x, y + 168)
  love.graphics.print("Frame: " .. tostring(state.previewIndex) .. "/" .. tostring(#animation.frames), x, y + 190)
  love.graphics.setColor(1, 1, 1, 1)
end

local function drawTimeline()
  local name, animation = getCurrentAnimation()

  if not state.sheet or not animation then
    return
  end

  local layout = state.layout
  local x = layout.timelineX
  local y = layout.timelineY
  local cell = 56
  local gap = 8
  local maxX = 1240

  state.timelineRects = {}

  love.graphics.setColor(0.08, 0.09, 0.11, 0.95)
  love.graphics.rectangle("fill", x - 14, y - 38, maxX - x + 18, 124)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Timeline: " .. (name or "-"), x, y - 24)

  for index, frameIndex in ipairs(animation.frames) do
    local cellX = x + (index - 1) * (cell + gap)
    local quad = state.sheet:get(frameIndex)

    if cellX + cell > maxX then
      break
    end

    state.timelineRects[index] = { x = cellX, y = y, w = cell, h = cell }

    if index == state.hoveredTimeline then
      love.graphics.setColor(0.20, 1, 0.45, 1)
    elseif index == state.previewIndex then
      love.graphics.setColor(1, 0.82, 0.20, 1)
    else
      love.graphics.setColor(0.20, 0.24, 0.30, 1)
    end

    love.graphics.rectangle("fill", cellX, y, cell, cell, 4, 4)

    if quad then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(state.sheet.image, quad, cellX + cell / 2, y + cell / 2, 0, 1, 1, state.params.frameW / 2, state.params.frameH / 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(tostring(frameIndex), cellX, y + cell + 3, cell, "center")
  end
end

local function drawStatus()
  love.graphics.setColor(0.04, 0.045, 0.06, 0.98)
  love.graphics.rectangle("fill", 366, 676, 874, 30)
  love.graphics.setColor(0.76, 0.82, 0.88, 1)
  love.graphics.print(state.status or "", 380, 684)
  love.graphics.setColor(1, 1, 1, 1)
end

function editor.load()
  Core.Scene.setBackgroundColor(0.02, 0.025, 0.03, 1, editor)
  loadSettings()
  rebuildSheet()
end

function editor.enter(previousScene)
  Core.Scene.setBackgroundColor(0.02, 0.025, 0.03, 1, editor)
end

function editor.update(dt)
  local name, animation = getCurrentAnimation()

  if not state.playing or not animation or #animation.frames <= 0 then
    return
  end

  state.previewTimer = state.previewTimer + dt

  local duration = 1 / math.max(1, animation.fps or 8)
  while state.previewTimer >= duration do
    state.previewTimer = state.previewTimer - duration
    state.previewIndex = state.previewIndex + 1

    if state.previewIndex > #animation.frames then
      if animation.loop then
        state.previewIndex = 1
      else
        state.previewIndex = #animation.frames
        state.playing = false
        break
      end
    end
  end
end

function editor.draw()
  drawPanel()
  drawPreview()
  drawSheet()
  drawTimeline()
  drawStatus()
end

function editor.mousemoved(x, y, dx, dy, istouch)
  state.hoveredFrame = nil
  state.hoveredTimeline = nil

  for index, rect in ipairs(state.frameRects) do
    if pointInRect(x, y, rect.x, rect.y, rect.w, rect.h) then
      state.hoveredFrame = index
      return
    end
  end

  for index, rect in ipairs(state.timelineRects) do
    if pointInRect(x, y, rect.x, rect.y, rect.w, rect.h) then
      state.hoveredTimeline = index
      return
    end
  end
end

function editor.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    Core.Scene.set(Menu)
    return
  end

  if key == "up" then
    state.selected = state.selected - 1
    if state.selected < 1 then
      state.selected = #params
    end
  elseif key == "down" then
    state.selected = state.selected + 1
    if state.selected > #params then
      state.selected = 1
    end
  elseif key == "left" or key == "right" then
    local step = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and 10 or 1
    changeParam(key == "left" and -step or step)
  elseif key == "s" then
    saveSettings()
  elseif key == "e" then
    exportAnimations()
  elseif key == "r" then
    reloadProject()
  elseif key == "tab" then
    local direction = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and -1 or 1
    changeAnimation(direction)
  elseif key == "space" then
    state.playing = not state.playing
  elseif key == "backspace" then
    clearCurrentAnimation()
  elseif key == "l" then
    toggleLoop()
  elseif key == "kp+" or key == "=" then
    changeFps(1)
  elseif key == "kp-" or key == "-" then
    changeFps(-1)
  end
end

function editor.mousepressed(x, y, button, istouch, presses)
  if button == 1 then
    for id, rect in pairs(state.buttons) do
      if pointInRect(x, y, rect.x, rect.y, rect.w, rect.h) then
        if id == "prevAnim" then
          changeAnimation(-1)
        elseif id == "nextAnim" then
          changeAnimation(1)
        elseif id == "fpsMinus" then
          changeFps(-1)
        elseif id == "fpsPlus" then
          changeFps(1)
        elseif id == "loop" then
          toggleLoop()
        elseif id == "play" then
          state.playing = not state.playing
        elseif id == "clear" then
          clearCurrentAnimation()
        elseif id == "export" then
          exportAnimations()
        end

        return
      end
    end

    for index, row in ipairs(state.rows) do
      if pointInRect(x, y, row.selectX, row.y, row.selectW, row.h) then
        state.selected = index
        return
      end

      if pointInRect(x, y, row.minusX, row.y, row.buttonW, row.h) then
        state.selected = index
        changeParam(-1)
        return
      end

      if pointInRect(x, y, row.plusX, row.y, row.buttonW, row.h) then
        state.selected = index
        changeParam(1)
        return
      end
    end

    for index, rect in ipairs(state.frameRects) do
      if pointInRect(x, y, rect.x, rect.y, rect.w, rect.h) then
        addFrameToAnimation(index)
        return
      end
    end
  elseif button == 2 then
    for index, rect in ipairs(state.timelineRects) do
      if pointInRect(x, y, rect.x, rect.y, rect.w, rect.h) then
        removeTimelineFrame(index)
        return
      end
    end
  end
end

return editor
