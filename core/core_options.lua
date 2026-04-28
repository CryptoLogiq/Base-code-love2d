local options = {
  items = {},
  page = nil,
  group = nil,
  waitingInputItem = nil,
  suppressInputFrame = false,
  buildIndex = 0,
  config = {},
  debug = false,
}

local defaultConfig = {
  title = "Options",
  x = 150,
  y = 150,
  w = 560,
  rowH = 42,
  rowSpacing = 12,
  font = nil,
  back = nil,
  autoActivate = true,
  groupName = "CoreOptions",
}

local function shallowCopy(src)
  local dst = {}

  for k, v in pairs(src or {}) do
    dst[k] = v
  end

  return dst
end

local function clamp(value, minValue, maxValue)
  if value < minValue then
    return minValue
  elseif value > maxValue then
    return maxValue
  end

  return value
end

local function roundToStep(value, step)
  if not step or step <= 0 then
    return value
  end

  return math.floor((value / step) + 0.5) * step
end

local function formatNumber(value)
  if math.floor(value) == value then
    return tostring(value)
  end

  return string.format("%.2f", value)
end

local function makeChoice(label, value)
  if type(label) == "table" then
    return {
      label = label.label or tostring(label.value or label[1] or "?"),
      value = label.value ~= nil and label.value or label[1],
      apply = label.apply,
    }
  end

  return {
    label = tostring(label),
    value = value ~= nil and value or label,
  }
end

local function findResolutionIndex(choices, w, h)
  for i, choice in ipairs(choices) do
    local value = choice.value

    if type(value) == "table" and value.w == w and value.h == h then
      return i
    end
  end

  return 1
end

local function getItemLabel(item)
  if item.type == "bool" then
    return item.label .. " : " .. (item.value and "Oui" or "Non")
  elseif item.type == "slider" then
    local percent = ""

    if item.asPercent then
      percent = " %"
      return item.label .. " : " .. tostring(math.floor(item.value * 100 + 0.5)) .. percent
    end

    return item.label .. " : " .. formatNumber(item.value)
  elseif item.type == "choice" then
    local choice = item.choices[item.index]

    if choice then
      return item.label .. " : " .. tostring(choice.label)
    end

    return item.label .. " : -"
  elseif item.type == "input" then
    local suffix = ""

    if options.waitingInputItem == item then
      suffix = " : appuie sur une touche..."
    else
      suffix = " : " .. Core.Input.bindingsToLabel(item.action)
    end

    return item.label .. suffix
  elseif item.type == "action" then
    return item.label
  end

  return item.label or "Option"
end

local function refreshItemButton(item)
  if item.button and item.button.setText then
    item.button:setText(getItemLabel(item))
  end
end

local function refreshAllButtons()
  for _, item in ipairs(options.items) do
    refreshItemButton(item)
  end
end

local function callOnChange(item)
  if type(item.onChange) == "function" then
    item.onChange(item.value, item)
  end
end

local function callOnChoiceChange(item)
  local choice = item.choices[item.index]

  if choice then
    item.value = choice.value

    if type(choice.apply) == "function" then
      choice.apply(choice.value, choice, item)
    end

    if type(item.onChange) == "function" then
      item.onChange(choice.value, choice, item)
    end
  end
end

local function toggleBool(item)
  item.value = not item.value
  callOnChange(item)
  refreshItemButton(item)
end

local function stepSlider(item, direction)
  local step = item.step or 1
  local value = item.value + step * direction

  value = roundToStep(value, step)
  value = clamp(value, item.min or 0, item.max or 1)

  item.value = value
  callOnChange(item)
  refreshItemButton(item)
end

local function stepChoice(item, direction)
  if not item.choices or #item.choices <= 0 then
    return
  end

  local index = item.index or 1
  index = index + direction

  if index < 1 then
    index = #item.choices
  elseif index > #item.choices then
    index = 1
  end

  item.index = index
  callOnChoiceChange(item)
  refreshItemButton(item)
end

local function activateItem(item)
  if item.type == "bool" then
    toggleBool(item)
  elseif item.type == "slider" then
    stepSlider(item, 1)
  elseif item.type == "choice" then
    stepChoice(item, 1)
  elseif item.type == "input" then
    options.waitingInputItem = item
    refreshAllButtons()
  elseif item.type == "action" and type(item.onAction) == "function" then
    item.onAction(item)
    refreshAllButtons()
  end
end

local function handleSelectedLeftRight()
  if options.waitingInputItem then
    return
  end

  if not options.group or not options.group.current then
    return
  end

  local item = options.group.current.optionItem

  if not item then
    return
  end

  if Core.Input.pressed("left") then
    if item.type == "bool" then
      toggleBool(item)
    elseif item.type == "slider" then
      stepSlider(item, -1)
    elseif item.type == "choice" then
      stepChoice(item, -1)
    end
  elseif Core.Input.pressed("right") then
    if item.type == "bool" then
      toggleBool(item)
    elseif item.type == "slider" then
      stepSlider(item, 1)
    elseif item.type == "choice" then
      stepChoice(item, 1)
    end
  end
end

local function captureToken(token)
  local item = options.waitingInputItem

  if not item or not token then
    return false
  end

  if item.action then
    Core.Input.setPrimaryBinding(item.action, token)
  end

  options.waitingInputItem = nil
  options.suppressInputFrame = true
  refreshAllButtons()

  if type(item.onChange) == "function" then
    item.onChange(token, item)
  end

  return true
end

function options.reset()
  options.items = {}
  options.page = nil
  options.group = nil
  options.waitingInputItem = nil
  options.suppressInputFrame = false
  options.config = shallowCopy(defaultConfig)
end

function options.setup(config)
  options.reset()

  for k, v in pairs(config or {}) do
    options.config[k] = v
  end

  return options
end

function options.addBool(id, label, value, onChange)
  local item = {
    id = id,
    type = "bool",
    label = label or id,
    value = value == true,
    onChange = onChange,
  }

  table.insert(options.items, item)
  return item
end

function options.addSlider(id, label, value, minValue, maxValue, step, onChange, asPercent)
  local item = {
    id = id,
    type = "slider",
    label = label or id,
    value = value or 0,
    min = minValue or 0,
    max = maxValue or 1,
    step = step or 1,
    onChange = onChange,
    asPercent = asPercent == true,
  }

  item.value = clamp(item.value, item.min, item.max)

  table.insert(options.items, item)
  return item
end

function options.addChoice(id, label, choices, index, onChange)
  local normalizedChoices = {}

  for _, choice in ipairs(choices or {}) do
    table.insert(normalizedChoices, makeChoice(choice))
  end

  local item = {
    id = id,
    type = "choice",
    label = label or id,
    choices = normalizedChoices,
    index = index or 1,
    onChange = onChange,
  }

  if item.index < 1 then
    item.index = 1
  elseif item.index > #item.choices then
    item.index = #item.choices
  end

  if item.choices[item.index] then
    item.value = item.choices[item.index].value
  end

  table.insert(options.items, item)
  return item
end

function options.addInput(action, label, onChange)
  local item = {
    id = "input_" .. tostring(action),
    type = "input",
    label = label or ("Input " .. tostring(action)),
    action = action,
    onChange = onChange,
  }

  table.insert(options.items, item)
  return item
end

function options.addAction(id, label, onAction)
  local item = {
    id = id,
    type = "action",
    label = label or id,
    onAction = onAction,
  }

  table.insert(options.items, item)
  return item
end

function options.addVolume(id, label, value)
  local currentValue = value

  if currentValue == nil and love and love.audio and love.audio.getVolume then
    currentValue = love.audio.getVolume()
  end

  return options.addSlider(id or "volume", label or "Volume général", currentValue or 1, 0, 1, 0.05, function(v)
    if love and love.audio and love.audio.setVolume then
      love.audio.setVolume(v)
    end
  end, true)
end

function options.addFullscreen(id, label)
  local isFullscreen = false

  if love and love.window and love.window.getFullscreen then
    isFullscreen = love.window.getFullscreen()
  end

  return options.addBool(id or "fullscreen", label or "Plein écran", isFullscreen, function(v)
    if love and love.window and love.window.setFullscreen then
      love.window.setFullscreen(v)
    end
  end)
end

function options.getResolutionChoices()
  local choices = {}
  local seen = {}

  if love and love.window and love.window.getFullscreenModes then
    local modes = love.window.getFullscreenModes()

    table.sort(modes, function(a, b)
      if a.width == b.width then
        return a.height < b.height
      end

      return a.width < b.width
    end)

    for _, mode in ipairs(modes) do
      local key = tostring(mode.width) .. "x" .. tostring(mode.height)

      if not seen[key] then
        seen[key] = true
        table.insert(choices, {
          label = key,
          value = { w = mode.width, h = mode.height },
        })
      end
    end
  end

  if #choices == 0 then
    local fallback = {
      { 800, 600 },
      { 1280, 720 },
      { 1600, 900 },
      { 1920, 1080 },
    }

    for _, size in ipairs(fallback) do
      table.insert(choices, {
        label = tostring(size[1]) .. "x" .. tostring(size[2]),
        value = { w = size[1], h = size[2] },
      })
    end
  end

  return choices
end

function options.addResolution(id, label)
  local choices = options.getResolutionChoices()
  local w, h = love.graphics.getDimensions()
  local index = findResolutionIndex(choices, w, h)

  return options.addChoice(id or "resolution", label or "Résolution", choices, index, function(value)
    if love and love.window and love.window.setMode and type(value) == "table" then
      local fullscreen = false

      if love.window.getFullscreen then
        fullscreen = love.window.getFullscreen()
      end

      love.window.setMode(value.w, value.h, {
        fullscreen = fullscreen,
        resizable = true,
      })
    end
  end)
end

function options.build()
  options.buildIndex = options.buildIndex + 1

  local cfg = options.config
  local groupName = tostring(cfg.groupName or "CoreOptions") .. "_" .. tostring(options.buildIndex)

  options.page = Core.Gui.Page.new(cfg.title or "Options")
  options.group = Core.Gui.button.newGroup(groupName)
  options.page:addGroup("main", options.group)

  local x = cfg.x or defaultConfig.x
  local y = cfg.y or defaultConfig.y
  local w = cfg.w or defaultConfig.w
  local rowH = cfg.rowH or defaultConfig.rowH
  local rowSpacing = cfg.rowSpacing or defaultConfig.rowSpacing

  for i, item in ipairs(options.items) do
    local bt = Core.Gui.button.new(getItemLabel(item), x, y + (i - 1) * (rowH + rowSpacing), w, rowH, options.group, function(self)
      activateItem(self.optionItem)
    end)

    bt.optionItem = item
    item.button = bt
  end

  options.group:load()
  options.group:selectFirstAvailable()

  if cfg.autoActivate ~= false then
    options.page:setActiveGroup("main")
  end

  refreshAllButtons()
  return options.page
end

function options.show()
  if options.page then
    options.page:show()

    if options.config.autoActivate ~= false then
      options.page:setActiveGroup("main")
    end
  end
end

function options.hide()
  if options.page then
    options.page:hide()
  end
end

function options.update(dt)
  if not options.page then
    return
  end

  if options.suppressInputFrame then
    local activeGroup = Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() or nil

    if activeGroup then
      activeGroup.active = false
    end

    options.page:update(dt)

    if activeGroup then
      activeGroup.active = true
    end

    options.suppressInputFrame = false
    return
  end

  options.page:update(dt)

  if options.waitingInputItem then
    if Core.Input.pressed("cancel") then
      options.waitingInputItem = nil
      options.suppressInputFrame = true
      refreshAllButtons()
    end

    return
  end

  handleSelectedLeftRight()

  if Core.Input.pressed("cancel") and type(options.config.back) == "function" then
    options.config.back()
  end
end

function options.draw()
  if not options.page or not options.page.visible then
    return
  end

  local cfg = options.config
  local x = cfg.x or defaultConfig.x
  local y = (cfg.y or defaultConfig.y) - 46

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(cfg.title or "Options", x, y)

  options.page:draw()

  local helpY = (cfg.y or defaultConfig.y) + #options.items * ((cfg.rowH or defaultConfig.rowH) + (cfg.rowSpacing or defaultConfig.rowSpacing)) + 20

  love.graphics.setColor(1, 1, 1, 1)

  if options.waitingInputItem then
    love.graphics.print("Remapping : appuie sur une touche, un bouton manette ou un clic souris. Echap/B pour annuler.", x, helpY)
  else
    love.graphics.print("Haut/Bas : naviguer | Gauche/Droite : modifier | Entrée/A : valider | Echap/B : retour", x, helpY)
  end
end

function options.mousepressed(x, y, button, istouch, presses)
  if not options.page then
    return false
  end

  if options.waitingInputItem then
    return captureToken("mouse:" .. tostring(button))
  end

  return options.page:mousepressed(x, y, button, istouch, presses)
end

function options.keypressed(key, scancode, isrepeat)
  if not options.waitingInputItem then
    return false
  end

  if key == "escape" then
    options.waitingInputItem = nil
    options.suppressInputFrame = true
    refreshAllButtons()
    return true
  end

  if isrepeat then
    return false
  end

  return captureToken("key:" .. key)
end

function options.gamepadpressed(joystick, button)
  if not options.waitingInputItem then
    return false
  end

  if button == "b" then
    options.waitingInputItem = nil
    options.suppressInputFrame = true
    refreshAllButtons()
    return true
  end

  return captureToken("pad:" .. button)
end

function options.gamepadaxis(joystick, axis, value)
  if not options.waitingInputItem then
    return false
  end

  if math.abs(value) < (Core.Input.deadzone or 0.25) then
    return false
  end

  local sign = value > 0 and "+" or "-"
  return captureToken("axis:" .. axis .. sign)
end

function options.isWaitingForInput()
  return options.waitingInputItem ~= nil
end

function options.getPage()
  return options.page
end

function options.getGroup()
  return options.group
end

options.reset()

return options
