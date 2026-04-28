local options = {
  items = {},
  page = nil,
  group = nil,
  waitingInputItem = nil,
  dropdownItem = nil,
  dropdownIndex = 1,
  dropdownScroll = 1,
  draggingSliderItem = nil,
  suppressInputFrame = false,
  buildIndex = 0,
  config = {},
  layout = nil,
  aspectFormat = "auto",
  settings = nil,
  settingsLoaded = false,
  applyingSettings = false,
  autoSave = true,
  settingsPath = "settings.lua",
  debug = false,
}

local defaultConfig = {
  title = "Options",
  x = 150,
  y = 150,
  w = 680,
  rowH = 42,
  rowSpacing = 10,
  font = nil,
  back = nil,
  autoActivate = true,
  groupName = "CoreOptions",
  dropdownMaxVisible = 8,
  responsive = true,
  marginX = 24,
  marginY = 24,
  titleGap = 34,
  helpGap = 12,
  minRowH = 30,
  minRowSpacing = 4,
}

local function shallowCopy(src)
  local dst = {}

  for k, v in pairs(src or {}) do
    dst[k] = v
  end

  return dst
end

local function serializeValue(value, indent)
  indent = indent or 0
  local valueType = type(value)

  if valueType == "number" or valueType == "boolean" then
    return tostring(value)
  elseif valueType == "string" then
    return string.format("%q", value)
  elseif valueType ~= "table" then
    return "nil"
  end

  local nextIndent = indent + 2
  local parts = { "{" }

  for k, v in pairs(value) do
    local key

    if type(k) == "string" and k:match("^[%a_][%w_]*$") then
      key = k
    else
      key = "[" .. serializeValue(k, nextIndent) .. "]"
    end

    table.insert(parts, string.rep(" ", nextIndent) .. key .. " = " .. serializeValue(v, nextIndent) .. ",")
  end

  table.insert(parts, string.rep(" ", indent) .. "}")
  return table.concat(parts, "\n")
end

local function copyTable(src)
  if type(src) ~= "table" then
    return src
  end

  local dst = {}

  for k, v in pairs(src) do
    dst[k] = copyTable(v)
  end

  return dst
end

local function sameOptionValue(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then
    return a == b
  end

  if a.w ~= nil or b.w ~= nil or a.h ~= nil or b.h ~= nil then
    return a.w == b.w and a.h == b.h
  end

  return false
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

local function formatSliderValue(item)
  if item.asPercent then
    return tostring(math.floor((item.value or 0) * 100 + 0.5)) .. " %"
  end

  return formatNumber(item.value or 0)
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

local function sameResolution(value, w, h)
  return type(value) == "table" and value.w == w and value.h == h
end

local function getScreenSize()
  if Core and Core.getDimensions then
    return Core.getDimensions()
  end

  if love and love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  end

  return 1280, 720
end

local function getWindowSize()
  if love and love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  end

  return getScreenSize()
end

local function getResolutionAspect(value)
  if type(value) ~= "table" or not value.w or not value.h or value.h == 0 then
    return nil
  end

  return value.w / value.h
end

local aspectFormats = {
  ["4/3"] = 4 / 3,
  ["5/4"] = 5 / 4,
  ["16/10"] = 16 / 10,
  ["16/9"] = 16 / 9,
  ["21/9"] = 21 / 9,
  ["32/9"] = 32 / 9,
}

local function normalizeAspectFormat(format)
  if aspectFormats[format] then
    return format
  end

  return "auto"
end

local function getDesktopAspect()
  if love and love.window and love.window.getDesktopDimensions then
    local w, h = love.window.getDesktopDimensions()

    if w and h and h > 0 then
      return w / h
    end
  end

  local sw, sh = getScreenSize()

  if sh and sh > 0 then
    return sw / sh
  end

  return 16 / 9
end

local function getAspectTarget(format)
  format = normalizeAspectFormat(format)

  if format == "auto" then
    return getDesktopAspect(), 0.04
  end

  return aspectFormats[format], 0.08
end

local function aspectMatchesFormat(value, format)
  local aspect = getResolutionAspect(value)

  if not aspect then
    return false
  end

  local target, tolerance = getAspectTarget(format)
  return math.abs(aspect - target) <= tolerance
end

local function getLayout()
  local cfg = options.config or defaultConfig
  local sw, sh = getScreenSize()
  local responsive = cfg.responsive ~= false
  local marginX = cfg.marginX or defaultConfig.marginX
  local marginY = cfg.marginY or defaultConfig.marginY
  local titleGap = cfg.titleGap or defaultConfig.titleGap
  local helpGap = cfg.helpGap or defaultConfig.helpGap
  local itemCount = math.max(1, #options.items)

  if not responsive then
    local x = cfg.x or defaultConfig.x
    local y = cfg.y or defaultConfig.y
    local w = cfg.w or defaultConfig.w
    local rowH = cfg.rowH or defaultConfig.rowH
    local rowSpacing = cfg.rowSpacing or defaultConfig.rowSpacing

    return {
      x = x,
      y = y,
      titleY = y - 46,
      w = w,
      rowH = rowH,
      rowSpacing = rowSpacing,
      helpY = y + #options.items * (rowH + rowSpacing) + 20,
      helpW = w,
      screenW = sw,
      screenH = sh,
    }
  end

  local maxW = math.max(220, sw - marginX * 2)
  local w = math.min(cfg.w or defaultConfig.w, maxW)
  local x = math.floor((sw - w) / 2)
  local y = math.max(marginY + titleGap, cfg.y or defaultConfig.y)
  local helpH = 42
  local availableH = math.max(160, sh - y - marginY - helpH - helpGap)
  local preferredRowH = cfg.rowH or defaultConfig.rowH
  local preferredSpacing = cfg.rowSpacing or defaultConfig.rowSpacing
  local minRowH = cfg.minRowH or defaultConfig.minRowH
  local minSpacing = cfg.minRowSpacing or defaultConfig.minRowSpacing
  local rowH = preferredRowH
  local rowSpacing = preferredSpacing
  local totalH = itemCount * rowH + math.max(0, itemCount - 1) * rowSpacing

  if totalH > availableH then
    local compactH = math.floor((availableH - math.max(0, itemCount - 1) * minSpacing) / itemCount)
    rowH = clamp(compactH, minRowH, preferredRowH)
    rowSpacing = minSpacing
    totalH = itemCount * rowH + math.max(0, itemCount - 1) * rowSpacing
  end

  return {
    x = x,
    y = y,
    titleY = math.max(8, y - titleGap),
    w = w,
    rowH = rowH,
    rowSpacing = rowSpacing,
    helpY = y + totalH + helpGap,
    helpW = w,
    screenW = sw,
    screenH = sh,
  }
end

local function applyLayout()
  if not options.group then
    return
  end

  local layout = getLayout()
  options.layout = layout

  for i, item in ipairs(options.items) do
    local bt = item.button

    if bt then
      bt.x = layout.x
      bt.y = layout.y + (i - 1) * (layout.rowH + layout.rowSpacing)
      bt.w = layout.w
      bt.h = layout.rowH
    end
  end
end

local function findResolutionIndex(choices, w, h)
  for i, choice in ipairs(choices) do
    if sameResolution(choice.value, w, h) then
      return i
    end
  end

  return 1
end

local function getItemLabel(item)
  if item.type == "bool" then
    return item.label .. " : " .. (item.value and "Oui" or "Non")
  elseif item.type == "slider" then
    return item.label
  elseif item.type == "choice" then
    return item.label
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

local function getSavedOptionValue(id)
  local settings = options.settings

  if settings and settings.options and id then
    return settings.options[id]
  end

  return nil
end

local function collectSettings()
  local settings = copyTable(options.settings or {})
  settings.version = 1
  settings.options = settings.options or {}

  for _, item in ipairs(options.items) do
    if item.id and item.type ~= "action" and item.type ~= "input" then
      settings.options[item.id] = copyTable(item.value)
    end
  end

  settings.aspectFormat = options.aspectFormat

  if Core and Core.getLetterbox then
    settings.letterbox = Core.getLetterbox()
  end

  if love and love.audio and love.audio.getVolume then
    settings.volume = love.audio.getVolume()
  end

  if love and love.window and love.window.getFullscreen then
    settings.fullscreen = love.window.getFullscreen()
  end

  if love and love.graphics and love.graphics.getDimensions then
    local w, h = love.graphics.getDimensions()
    settings.resolution = { w = w, h = h }
  end

  if Core and Core.Input then
    if Core.Input.getKeyboardLayout then
      settings.keyboardLayout = Core.Input.getKeyboardLayout()
    end

    if Core.Input.getAllBindings then
      settings.inputBindings = Core.Input.getAllBindings()
    end
  end

  return settings
end

local function applySettingsToCore(settings)
  if type(settings) ~= "table" then
    return
  end

  options.applyingSettings = true

  if settings.volume and love and love.audio and love.audio.setVolume then
    love.audio.setVolume(settings.volume)
  end

  if settings.letterbox ~= nil and Core and Core.setLetterbox then
    Core.setLetterbox(settings.letterbox)
  end

  if Core and Core.Input then
    if settings.keyboardLayout and Core.Input.setKeyboardLayout then
      Core.Input.setKeyboardLayout(settings.keyboardLayout)
    end

    if settings.inputBindings and Core.Input.setAllBindings then
      Core.Input.setAllBindings(settings.inputBindings)
    end
  end

  if love and love.window and love.window.setMode and settings.resolution and settings.resolution.w and settings.resolution.h then
    local fullscreen = settings.fullscreen == true
    pcall(function()
      love.window.setMode(settings.resolution.w, settings.resolution.h, {
        fullscreen = fullscreen,
        resizable = true,
      })
    end)
  elseif love and love.window and love.window.setFullscreen and settings.fullscreen ~= nil then
    pcall(function()
      love.window.setFullscreen(settings.fullscreen == true)
    end)
  end

  options.aspectFormat = normalizeAspectFormat(settings.aspectFormat)
  options.applyingSettings = false
end

local function autosave()
  if options.autoSave == false or options.applyingSettings then
    return false
  end

  return options.saveSettings()
end

local function callOnChange(item)
  if type(item.onChange) == "function" then
    item.onChange(item.value, item)
  end

  autosave()
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

    autosave()
  end
end

local function toggleBool(item)
  item.value = not item.value
  callOnChange(item)
  refreshItemButton(item)
end

local function stepSlider(item, direction)
  local step = item.step or 1
  local value = (item.value or 0) + step * direction

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

local function openDropdown(item)
  if not item or item.type ~= "choice" then
    return false
  end

  options.dropdownItem = item
  options.dropdownIndex = item.index or 1
  options.dropdownScroll = 1
  return true
end

local function closeDropdown(apply)
  local item = options.dropdownItem

  if item and apply then
    item.index = options.dropdownIndex or item.index or 1
    callOnChoiceChange(item)
    refreshItemButton(item)
  end

  options.dropdownItem = nil
  options.dropdownIndex = 1
  options.dropdownScroll = 1
end

local function activateItem(item)
  if item.type == "bool" then
    toggleBool(item)
  elseif item.type == "slider" then
    stepSlider(item, 1)
  elseif item.type == "choice" then
    if options.dropdownItem == item then
      closeDropdown(false)
    else
      openDropdown(item)
    end
  elseif item.type == "input" then
    options.waitingInputItem = item
    closeDropdown(false)
    refreshAllButtons()
  elseif item.type == "action" and type(item.onAction) == "function" then
    closeDropdown(false)
    item.onAction(item)
    refreshAllButtons()
    autosave()
  end
end

local function updatePageVisualOnly(dt)
  local activeGroup = Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() or nil
  local wasActive = activeGroup and activeGroup.active or false

  if activeGroup then
    activeGroup.active = false
  end

  if options.page then
    options.page:update(dt)
  end

  if activeGroup then
    activeGroup.active = wasActive
  end
end

local function drawPageVisualOnly()
  local activeGroup = Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() or nil
  local wasActive = activeGroup and activeGroup.active or false

  if activeGroup then
    activeGroup.active = false
  end

  if options.page then
    options.page:draw()
  end

  if activeGroup then
    activeGroup.active = wasActive
  end
end

local function handleSelectedLeftRight()
  if options.waitingInputItem or options.dropdownItem then
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

  autosave()

  return true
end

local function getButton(item)
  return item and item.button or nil
end

local function getSliderRect(item)
  local bt = getButton(item)

  if not bt then
    return nil
  end

  local valueW = 58
  local x = bt.x + bt.w * 0.46
  local w = bt.w * 0.34
  local h = 8
  local y = bt.y + bt.h / 2 - h / 2

  return {
    x = x,
    y = y,
    w = w,
    h = h,
    valueX = x + w + 12,
    valueW = valueW,
  }
end

local function getChoiceBoxRect(item)
  local bt = getButton(item)

  if not bt then
    return nil
  end

  return {
    x = bt.x + bt.w * 0.46,
    y = bt.y + 6,
    w = bt.w * 0.48,
    h = bt.h - 12,
  }
end

local function pointInRect(x, y, rect)
  return rect and x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h
end

local function setSliderFromMouse(item, mouseX)
  local rect = getSliderRect(item)

  if not rect then
    return false
  end

  local minValue = item.min or 0
  local maxValue = item.max or 1
  local ratio = clamp((mouseX - rect.x) / rect.w, 0, 1)
  local value = minValue + (maxValue - minValue) * ratio

  value = roundToStep(value, item.step or 0)
  value = clamp(value, minValue, maxValue)

  if value ~= item.value then
    item.value = value
    callOnChange(item)
    refreshItemButton(item)
  end

  return true
end

local function getSliderRatio(item)
  local minValue = item.min or 0
  local maxValue = item.max or 1

  if maxValue == minValue then
    return 0
  end

  return clamp(((item.value or minValue) - minValue) / (maxValue - minValue), 0, 1)
end

local function getDropdownMetrics(item)
  local box = getChoiceBoxRect(item)

  if not box then
    return nil
  end

  local maxVisible = item.maxVisible or options.config.dropdownMaxVisible or defaultConfig.dropdownMaxVisible
  local visibleCount = math.min(#item.choices, maxVisible)
  local rowH = item.dropdownRowH or 30
  local listH = visibleCount * rowH
  local listY = box.y + box.h + 4
  local _, screenH = getScreenSize()

  if listY + listH > screenH - 10 then
    listY = box.y - listH - 4
  end

  return {
    x = box.x,
    y = listY,
    w = box.w,
    h = listH,
    rowH = rowH,
    visibleCount = visibleCount,
    maxVisible = maxVisible,
  }
end

local function ensureDropdownScroll()
  local item = options.dropdownItem

  if not item then
    return
  end

  local maxVisible = item.maxVisible or options.config.dropdownMaxVisible or defaultConfig.dropdownMaxVisible
  local count = #item.choices

  if count <= maxVisible then
    options.dropdownScroll = 1
    return
  end

  local index = options.dropdownIndex or item.index or 1
  local scroll = options.dropdownScroll or 1

  if index < scroll then
    scroll = index
  elseif index > scroll + maxVisible - 1 then
    scroll = index - maxVisible + 1
  end

  options.dropdownScroll = clamp(scroll, 1, math.max(1, count - maxVisible + 1))
end

local function moveDropdown(direction)
  local item = options.dropdownItem

  if not item or not item.choices or #item.choices == 0 then
    return
  end

  local index = (options.dropdownIndex or item.index or 1) + direction

  if index < 1 then
    index = #item.choices
  elseif index > #item.choices then
    index = 1
  end

  options.dropdownIndex = index
  ensureDropdownScroll()
end

local function handleDropdownInput()
  if not options.dropdownItem then
    return false
  end

  if Core.Input.pressed("down") then
    moveDropdown(1)
    return true
  elseif Core.Input.pressed("up") then
    moveDropdown(-1)
    return true
  elseif Core.Input.pressed("left") then
    moveDropdown(-1)
    return true
  elseif Core.Input.pressed("right") then
    moveDropdown(1)
    return true
  elseif Core.Input.pressed("validate") then
    closeDropdown(true)
    options.suppressInputFrame = true
    return true
  elseif Core.Input.pressed("cancel") then
    closeDropdown(false)
    options.suppressInputFrame = true
    return true
  end

  return false
end

local function updateDropdownMouseHover()
  local item = options.dropdownItem

  if not item or not love.mouse or not love.mouse.getPosition then
    return false
  end

  local inputMode = Core and Core.Gui and Core.Gui.getInputMode and Core.Gui.getInputMode() or "mouse"

  if inputMode ~= "mouse" then
    return false
  end

  local metrics = getDropdownMetrics(item)

  if not metrics then
    return false
  end

  local mx, my = love.mouse.getPosition()

  if Core and Core.toVirtual then
    mx, my = Core.toVirtual(mx, my)
  end

  if not pointInRect(mx, my, metrics) then
    return false
  end

  local rowIndex = math.floor((my - metrics.y) / metrics.rowH)
  local choiceIndex = (options.dropdownScroll or 1) + rowIndex

  if choiceIndex < 1 or choiceIndex > #item.choices then
    return false
  end

  options.dropdownIndex = choiceIndex
  ensureDropdownScroll()
  return true
end

local function drawText(text, x, y, w, h, align)
  local font = love.graphics.getFont()
  local _, lines = font:getWrap(text, w)
  local lineH = font:getHeight()
  local totalH = #lines * lineH
  local textY = y + h / 2 - totalH / 2

  love.graphics.printf(text, x, textY, w, align or "left")
end

local function drawSlider(item)
  local bt = getButton(item)
  local rect = getSliderRect(item)

  if not bt or not rect or bt.visible == false then
    return
  end

  local ratio = getSliderRatio(item)
  local knobX = rect.x + rect.w * ratio
  local active = bt.visualActive == true

  love.graphics.setColor(0.25, 0.25, 0.25, 1)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 4, 4)

  love.graphics.setColor(0, active and 1 or 0.65, 0, 1)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w * ratio, rect.h, 4, 4)

  love.graphics.setColor(0.05, 0.05, 0.05, 1)
  love.graphics.circle("fill", knobX, rect.y + rect.h / 2, 8)

  love.graphics.setColor(0, active and 1 or 0.65, 0, 1)
  love.graphics.circle("line", knobX, rect.y + rect.h / 2, 8)

  love.graphics.setColor(0, 0, 0, 1)
  drawText(formatSliderValue(item), rect.valueX, bt.y, rect.valueW, bt.h, "right")
end

local function getCurrentChoiceLabel(item)
  local choice = item.choices and item.choices[item.index]
  return choice and tostring(choice.label) or "-"
end

local function drawChoiceBox(item)
  local bt = getButton(item)
  local rect = getChoiceBoxRect(item)

  if not bt or not rect or bt.visible == false then
    return
  end

  local active = bt.visualActive == true or options.dropdownItem == item

  love.graphics.setColor(0.92, 0.92, 0.92, 1)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 6, 6)

  love.graphics.setColor(0, active and 1 or 0.35, 0, 1)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 6, 6)

  love.graphics.setColor(0, 0, 0, 1)
  drawText(getCurrentChoiceLabel(item), rect.x + 10, rect.y, rect.w - 34, rect.h, "left")
  drawText(options.dropdownItem == item and "▲" or "▼", rect.x + rect.w - 26, rect.y, 20, rect.h, "center")
end

local function drawDropdown()
  local item = options.dropdownItem

  if not item then
    return
  end

  ensureDropdownScroll()

  local metrics = getDropdownMetrics(item)

  if not metrics then
    return
  end

  love.graphics.setColor(0.95, 0.95, 0.95, 1)
  love.graphics.rectangle("fill", metrics.x, metrics.y, metrics.w, metrics.h, 6, 6)
  love.graphics.setColor(0, 0.8, 0, 1)
  love.graphics.rectangle("line", metrics.x, metrics.y, metrics.w, metrics.h, 6, 6)

  local first = options.dropdownScroll or 1
  local last = math.min(#item.choices, first + metrics.visibleCount - 1)

  for index = first, last do
    local choice = item.choices[index]
    local rowIndex = index - first
    local y = metrics.y + rowIndex * metrics.rowH
    local isActive = index == options.dropdownIndex

    if isActive then
      love.graphics.setColor(0, 0.55, 0.18, 1)
      love.graphics.rectangle("fill", metrics.x + 2, y + 2, metrics.w - 4, metrics.rowH - 4, 4, 4)
    end

    if isActive then
      love.graphics.setColor(1, 1, 1, 1)
    else
      love.graphics.setColor(0, 0, 0, 1)
    end

    drawText(tostring(choice.label), metrics.x + 10, y, metrics.w - 20, metrics.rowH, "left")
  end

  if #item.choices > metrics.visibleCount then
    local scrollInfo = tostring(options.dropdownIndex or 1) .. "/" .. tostring(#item.choices)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    drawText(scrollInfo, metrics.x + metrics.w - 62, metrics.y, 54, metrics.rowH, "right")
  end
end

local function drawWidgets()
  for _, item in ipairs(options.items) do
    if item.type == "slider" then
      drawSlider(item)
    elseif item.type == "choice" then
      drawChoiceBox(item)
    end
  end

  drawDropdown()
end

local function handleDropdownMouse(x, y)
  local item = options.dropdownItem

  if not item then
    return false
  end

  local metrics = getDropdownMetrics(item)

  if metrics and pointInRect(x, y, metrics) then
    local rowIndex = math.floor((y - metrics.y) / metrics.rowH)
    local choiceIndex = (options.dropdownScroll or 1) + rowIndex

    if choiceIndex >= 1 and choiceIndex <= #item.choices then
      options.dropdownIndex = choiceIndex
      closeDropdown(true)
      options.suppressInputFrame = true
      return true
    end
  end

  local box = getChoiceBoxRect(item)

  if box and pointInRect(x, y, box) then
    closeDropdown(false)
    options.suppressInputFrame = true
    return true
  end

  closeDropdown(false)
  options.suppressInputFrame = true
  return true
end

local function handleWidgetMousepressed(x, y, button)
  if button ~= 1 then
    return false
  end

  if options.dropdownItem then
    return handleDropdownMouse(x, y)
  end

  for _, item in ipairs(options.items) do
    if item.type == "slider" then
      local rect = getSliderRect(item)

      if pointInRect(x, y, rect) then
        options.draggingSliderItem = item
        setSliderFromMouse(item, x)

        if item.button and item.button.group then
          item.button.group:selectIndex(item.button.id or 1)
          Core.Gui.setActiveGroup(item.button.group)
        end

        return true
      end
    elseif item.type == "choice" then
      local rect = getChoiceBoxRect(item)

      if pointInRect(x, y, rect) then
        if item.button and item.button.group then
          item.button.group:selectIndex(item.button.id or 1)
          Core.Gui.setActiveGroup(item.button.group)
        end

        openDropdown(item)
        options.suppressInputFrame = true
        return true
      end
    end
  end

  return false
end

function options.reset()
  options.items = {}
  options.page = nil
  options.group = nil
  options.waitingInputItem = nil
  options.dropdownItem = nil
  options.dropdownIndex = 1
  options.dropdownScroll = 1
  options.draggingSliderItem = nil
  options.suppressInputFrame = false
  options.layout = nil
  options.aspectFormat = normalizeAspectFormat(options.settings and options.settings.aspectFormat)
  options.config = shallowCopy(defaultConfig)
end

function options.loadSettings(path)
  options.settingsPath = path or options.settingsPath
  options.settingsLoaded = true

  if not love or not love.filesystem or not love.filesystem.getInfo then
    options.settings = {}
    return options.settings
  end

  if not love.filesystem.getInfo(options.settingsPath) then
    options.settings = {}
    return options.settings
  end

  local chunk, loadError = love.filesystem.load(options.settingsPath)

  if not chunk then
    print("Could not load settings: " .. tostring(loadError))
    options.settings = {}
    return options.settings
  end

  local ok, data = pcall(chunk)

  if ok and type(data) == "table" then
    options.settings = data
  else
    print("Could not read settings: " .. tostring(data))
    options.settings = {}
  end

  applySettingsToCore(options.settings)
  return options.settings
end

function options.applySettings()
  if not options.settingsLoaded then
    options.loadSettings()
  else
    applySettingsToCore(options.settings)
  end
end

function options.saveSettings(path)
  options.settingsPath = path or options.settingsPath

  if not love or not love.filesystem or not love.filesystem.write then
    return false
  end

  options.settings = collectSettings()

  local content = "return " .. serializeValue(options.settings) .. "\n"
  local ok, err = love.filesystem.write(options.settingsPath, content)

  if not ok then
    print("Could not save settings: " .. tostring(err))
    return false
  end

  return true
end

function options.setup(config)
  options.reset()

  if not options.settingsLoaded then
    options.loadSettings()
  end

  for k, v in pairs(config or {}) do
    options.config[k] = v
  end

  return options
end

function options.newToggle(id, label, value, onChange)
  local savedValue = getSavedOptionValue(id)

  if savedValue ~= nil then
    value = savedValue
  end

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

function options.newSlider(id, label, value, minValue, maxValue, step, onChange, asPercent)
  local savedValue = getSavedOptionValue(id)

  if type(savedValue) == "number" then
    value = savedValue
  end

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

function options.newChoice(id, label, choices, index, onChange)
  local normalizedChoices = {}

  for _, choice in ipairs(choices or {}) do
    table.insert(normalizedChoices, makeChoice(choice))
  end

  local savedValue = getSavedOptionValue(id)

  if savedValue ~= nil then
    for i, choice in ipairs(normalizedChoices) do
      if sameOptionValue(choice.value, savedValue) then
        index = i
        break
      end
    end
  end

  local item = {
    id = id,
    type = "choice",
    label = label or id,
    choices = normalizedChoices,
    index = index or 1,
    onChange = onChange,
    maxVisible = options.config.dropdownMaxVisible or defaultConfig.dropdownMaxVisible,
  }

  if #item.choices <= 0 then
    item.index = 1
  elseif item.index < 1 then
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


function options.newInput(action, label, onChange)
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

function options.newAction(id, label, onAction)
  local item = {
    id = id,
    type = "action",
    label = label or id,
    onAction = onAction,
  }

  table.insert(options.items, item)
  return item
end

function options.newVolume(id, label, value)
  local currentValue = value

  if currentValue == nil and love and love.audio and love.audio.getVolume then
    currentValue = love.audio.getVolume()
  end

  return options.newSlider(id or "volume", label or "Volume général", currentValue or 1, 0, 1, 0.05, function(v)
    if love and love.audio and love.audio.setVolume then
      love.audio.setVolume(v)
    end
  end, true)
end

function options.newFullscreen(id, label)
  local isFullscreen = false

  if love and love.window and love.window.getFullscreen then
    isFullscreen = love.window.getFullscreen()
  end

  return options.newToggle(id or "fullscreen", label or "Plein écran", isFullscreen, function(v)
    if love and love.window and love.window.setFullscreen then
      local w, h = love.graphics.getDimensions()
      love.window.setMode(w, h, {
        fullscreen = v,
        resizable = true,
      })
    end
  end)
end

function options.newLetterbox(id, label)
  local enabled = true

  if Core and Core.getLetterbox then
    enabled = Core.getLetterbox()
  end

  return options.newToggle(id or "letterbox", label or "Bandes noires", enabled, function(v)
    if Core and Core.setLetterbox then
      Core.setLetterbox(v)
    end
  end)
end

function options.newKeyboardLayout(id, label)
  local currentLayout = "auto"

  if Core and Core.Input and Core.Input.getKeyboardLayout then
    currentLayout = Core.Input.getKeyboardLayout()
  end

  local choices = {
    { label = "Auto", value = "auto" },
    { label = "AZERTY", value = "azerty" },
    { label = "QWERTY", value = "qwerty" },
  }

  local index = 1

  for i, choice in ipairs(choices) do
    if choice.value == currentLayout then
      index = i
      break
    end
  end

  return options.newChoice(id or "keyboard_layout", label or "Clavier", choices, index, function(value)
    if not Core or not Core.Input then
      return
    end

    if value == "auto" and Core.Input.detectKeyboardLayout then
      Core.Input.detectKeyboardLayout()
    elseif Core.Input.setKeyboardLayout then
      Core.Input.setKeyboardLayout(value)
    end

    refreshAllButtons()
  end)
end

function options.getResolutionChoices(format)
  format = normalizeAspectFormat(format or options.aspectFormat)

  local choices = {}
  local seen = {}

  local function pushResolution(w, h)
    if not w or not h then
      return
    end

    local key = tostring(w) .. "x" .. tostring(h)

    if not seen[key] then
      seen[key] = true
      table.insert(choices, {
        label = key,
        value = { w = w, h = h },
      })
    end
  end

  if love and love.window and love.window.getFullscreenModes then
    local modes = love.window.getFullscreenModes()

    table.sort(modes, function(a, b)
      if a.width == b.width then
        return a.height < b.height
      end

      return a.width < b.width
    end)

    for _, mode in ipairs(modes) do
      pushResolution(mode.width, mode.height)
    end
  end

  if love and love.window and love.window.getDesktopDimensions then
    local desktopW, desktopH = love.window.getDesktopDimensions()
    pushResolution(desktopW, desktopH)
  end

  if #choices == 0 then
    local fallback = {
      { 800, 600 },
      { 1024, 768 },
      { 1280, 720 },
      { 1366, 768 },
      { 1600, 900 },
      { 1920, 1080 },
      { 2560, 1440 },
    }

    for _, size in ipairs(fallback) do
      pushResolution(size[1], size[2])
    end
  end

  table.sort(choices, function(a, b)
    if a.value.w == b.value.w then
      return a.value.h < b.value.h
    end

    return a.value.w < b.value.w
  end)

  local filtered = {}

  for _, choice in ipairs(choices) do
    if aspectMatchesFormat(choice.value, format) then
      table.insert(filtered, choice)
    end
  end

  return #filtered > 0 and filtered or choices
end

local function refreshResolutionChoiceItems()
  local format = normalizeAspectFormat(options.aspectFormat)

  for _, item in ipairs(options.items) do
    if item.resolutionChoice then
      local currentW, currentH = getWindowSize()
      item.choices = options.getResolutionChoices(format)
      item.index = findResolutionIndex(item.choices, currentW, currentH)
      item.value = item.choices[item.index] and item.choices[item.index].value or nil
      item.maxVisible = options.config.dropdownMaxVisible or defaultConfig.dropdownMaxVisible
      refreshItemButton(item)
    end
  end
end

function options.newAspectFormat(id, label)
  local choices = {
    { label = "Auto écran", value = "auto" },
    { label = "4/3", value = "4/3" },
    { label = "5/4", value = "5/4" },
    { label = "16/10", value = "16/10" },
    { label = "16/9", value = "16/9" },
    { label = "21/9", value = "21/9" },
    { label = "32/9", value = "32/9" },
  }

  local item = options.newChoice(id or "aspect_format", label or "Format", choices, 1, function(value)
    options.aspectFormat = normalizeAspectFormat(value)
    refreshResolutionChoiceItems()
  end)

  item.aspectFormatChoice = true
  options.aspectFormat = normalizeAspectFormat(item.value)
  return item
end

function options.newResolution(id, label)
  local choices = options.getResolutionChoices(options.aspectFormat)
  local w, h = love.graphics.getDimensions()
  local index = findResolutionIndex(choices, w, h)

  local item = options.newChoice(id or "resolution", label or "Résolution", choices, index, function(value)
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

  item.resolutionChoice = true
  return item
end

function options.build()
  options.buildIndex = options.buildIndex + 1

  local cfg = options.config
  local groupName = tostring(cfg.groupName or "CoreOptions") .. "_" .. tostring(options.buildIndex)

  options.page = Core.Gui.newPage(cfg.title or "Options")
  options.group = Core.Gui.newButtonGroup(groupName)
  options.page:addGroup("main", options.group)

  local layout = getLayout()

  for i, item in ipairs(options.items) do
    local bt = Core.Gui.newButton(getItemLabel(item), layout.x, layout.y + (i - 1) * (layout.rowH + layout.rowSpacing), layout.w, layout.rowH, options.group, function(self)
      activateItem(self.optionItem)
    end)

    bt.optionItem = item
    bt.textAlign = "left"
    bt.textPadding = 14
    item.button = bt
  end

  applyLayout()
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
  closeDropdown(false)
  options.draggingSliderItem = nil

  if options.page then
    options.page:hide()
  end
end

function options.update(dt)
  if not options.page then
    return
  end

  applyLayout()

  if options.draggingSliderItem then
    if love.mouse and love.mouse.isDown and love.mouse.isDown(1) then
      local x = love.mouse.getX()
      setSliderFromMouse(options.draggingSliderItem, x)
    else
      options.draggingSliderItem = nil
    end
  end

  if options.suppressInputFrame then
    updatePageVisualOnly(dt)
    options.suppressInputFrame = false
    return
  end

  if options.dropdownItem then
    updatePageVisualOnly(dt)
    updateDropdownMouseHover()
    handleDropdownInput()
    return
  end

  if options.waitingInputItem then
    updatePageVisualOnly(dt)

    if Core.Input.pressed("cancel") then
      options.waitingInputItem = nil
      options.suppressInputFrame = true
      refreshAllButtons()
    end

    return
  end

  options.page:update(dt)

  handleSelectedLeftRight()

  if Core.Input.pressed("cancel") and type(options.config.back) == "function" then
    options.config.back()
  end
end

function options.draw()
  if not options.page or not options.page.visible then
    return
  end

  applyLayout()

  local cfg = options.config
  local layout = options.layout or getLayout()
  local x = layout.x
  local y = layout.titleY

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(cfg.title or "Options", x, y)

  if options.dropdownItem then
    drawPageVisualOnly()
  else
    options.page:draw()
  end

  drawWidgets()

  local helpY = layout.helpY

  love.graphics.setColor(1, 1, 1, 1)

  if options.waitingInputItem then
    love.graphics.printf("Remapping : appuie sur une touche, un bouton manette ou un clic souris. Echap/B pour annuler.", x, helpY, layout.helpW, "left")
  elseif options.dropdownItem then
    love.graphics.printf("Liste : Haut/Bas pour choisir | Entrée/A pour valider | Echap/B pour fermer", x, helpY, layout.helpW, "left")
  else
    love.graphics.printf("Haut/Bas : naviguer | Gauche/Droite : ajuster | Entrée/A : ouvrir/valider | Echap/B : retour", x, helpY, layout.helpW, "left")
  end
end

function options.mousepressed(x, y, button, istouch, presses)
  if not options.page then
    return false
  end

  applyLayout()

  if options.waitingInputItem then
    return captureToken("mouse:" .. tostring(button))
  end

  if handleWidgetMousepressed(x, y, button) then
    return true
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

function options.isDropdownOpen()
  return options.dropdownItem ~= nil
end

function options.getPage()
  return options.page
end

function options.getGroup()
  return options.group
end

options.reset()

return options
