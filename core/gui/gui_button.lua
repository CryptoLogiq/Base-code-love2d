local button = { lst_group = {}, debug = true }

-- =========================================================
-- BUTTON METHODS
-- =========================================================

local function load(self)
end

local function getGroup(self)
  return self.group or false
end

local function setFunction(self, fct)
  if type(fct) == "function" then
    self.fct = fct
    self.callback = fct
  end

  return self
end

local function onClick(self, fct)
  return self:setFunction(fct)
end

local function setFont(self, font)
  if not font then
    return self
  end

  self.font = font
  self.text.data = love.graphics.newText(font, self.name)
  self.text.w, self.text.h = self.text.data:getDimensions()

  return self
end

local function setText(self, text, font)
  self.name = text or self.name
  self.text.data = love.graphics.newText(font or self.font or love.graphics.getFont(), self.name)
  self.text.w, self.text.h = self.text.data:getDimensions()

  return self
end

local function setVisible(self, visible)
  self.visible = visible ~= false

  if not self.visible then
    self.hovered = false
    self.selected = false
    self.visualActive = false
  end

  if self.group and self.group.applyLayout then
    self.group:applyLayout()

    if self.group.current == self and self.group.selectFirstAvailable then
      self.group:selectFirstAvailable()
    end
  end

  return self
end

local function setEnabled(self, enabled)
  self.enabled = enabled ~= false

  if not self.enabled then
    self.hovered = false
    self.selected = false
    self.visualActive = false
  end

  return self
end

local function setTextAlign(self, align, padding)
  if align == "left" or align == "center" or align == "right" then
    self.textAlign = align
  end

  if padding then
    self.textPadding = padding
  end

  return self
end

local function isSelectable(self)
  return self.visible ~= false and self.enabled ~= false
end

local function update(self, dt)
  if self.visible == false then
    self.hovered = false
    return
  end

  self.cx = self.x + self.w / 2
  self.cy = self.y + self.h / 2
  self.oy = 0 - (self.h / 2)

  local txt = self.text
  txt.ox = txt.w / 2
  txt.oy = txt.h / 2

  if self.textAlign == "left" then
    txt.x = self.x + (self.textPadding or 12)
    txt.y = self.cy - txt.oy
  elseif self.textAlign == "right" then
    txt.x = self.x + self.w - txt.w - (self.textPadding or 12)
    txt.y = self.cy - txt.oy
  else
    txt.x = self.cx - txt.ox
    txt.y = self.cy - txt.oy
  end

  if self.enabled == false then
    self.hovered = false
    return
  end

  self.hovered = Core.Collision.aabbMouse(Core.Mouse, self)
end

local function draw(self)
  if self.visible == false then
    return
  end

  local bodyColor = self.color

  if self.enabled == false and self.disabledColor then
    bodyColor = self.disabledColor
  end

  love.graphics.setColor(bodyColor[1], bodyColor[2], bodyColor[3], bodyColor[4] or 1)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.rounded, self.rounded)

  local txt = self.text

  if self.enabled == false and txt.colorDisabled then
    love.graphics.setColor(txt.colorDisabled[1], txt.colorDisabled[2], txt.colorDisabled[3], txt.colorDisabled[4] or 1)
  elseif self.visualActive or (not self.group and (self.selected or self.hovered)) then
    love.graphics.setColor(txt.colorSelect[1], txt.colorSelect[2], txt.colorSelect[3], txt.colorSelect[4] or 1)
  else
    love.graphics.setColor(txt.color[1], txt.color[2], txt.color[3], txt.color[4] or 1)
  end

  love.graphics.draw(txt.data, txt.x, txt.y)
  love.graphics.setColor(1, 1, 1, 1)
end

local function isSelect(self)
  if not self:isSelectable() then
    return false
  end

  if self.group then
    self.group:isSelect(self, self.group)
  else
    self.selected = true
  end

  return true
end

local function mousepressed(self)
  if not self:isSelectable() then
    return false
  end

  if self.fct then
    self:fct()
    return true
  end

  return false
end

local function keypressed(self)
  if not self:isSelectable() then
    return false
  end

  if self.fct then
    self:fct()
    return true
  end

  return false
end

-- =========================================================
-- GROUP METHODS
-- =========================================================

local function groupLoad(group)
  if group.applyLayout then
    group:applyLayout()
  end

  for n = 1, #group do
    group[n]:load()
  end
end

local function groupIsButtonSelectable(group, bt)
  return bt and bt.visible ~= false and bt.enabled ~= false
end

local function groupSelectIndex(group, index)
  if #group <= 0 then
    group.current = nil
    return nil
  end

  if index < 1 then
    index = #group
  elseif index > #group then
    index = 1
  end

  local normalizedIndex = index

  for offset = 0, #group - 1 do
    local candidateIndex = ((normalizedIndex - 1 + offset) % #group) + 1
    local bt = group[candidateIndex]

    if groupIsButtonSelectable(group, bt) then
      group.selectedIndex = candidateIndex
      group.current = bt

      for n = 1, #group do
        group[n].selected = n == candidateIndex
      end

      return group.current
    end
  end

  group.current = nil

  for n = 1, #group do
    group[n].selected = false
  end

  return nil
end

local function groupSelectFirstAvailable(group)
  return group:selectIndex(group.selectedIndex or 1)
end

local function groupSelectNext(group)
  local index = group.selectedIndex or 1
  return group:selectIndex(index + 1)
end

local function groupSelectPrevious(group)
  local index = group.selectedIndex or 1

  if #group <= 0 then
    return nil
  end

  for offset = 1, #group do
    local candidateIndex = ((index - 1 - offset) % #group) + 1
    local bt = group[candidateIndex]

    if groupIsButtonSelectable(group, bt) then
      return group:selectIndex(candidateIndex)
    end
  end

  return nil
end

local function groupValidate(group)
  if group.current and groupIsButtonSelectable(group, group.current) and group.current.fct then
    group.current:fct()
    return true
  end

  return false
end

local function groupGetHovered(group)
  if group.visible == false or group.enabled == false then
    return nil
  end

  for n = 1, #group do
    local bt = group[n]

    if groupIsButtonSelectable(group, bt) and bt.hovered then
      return bt, n
    end
  end

  return nil
end

local function groupGetVisualCurrent(group)
  if group.visible == false or group.enabled == false then
    return nil
  end

  local hovered = group:getHovered()
  local mode = "keyboard"

  if Core and Core.Gui and Core.Gui.getInputMode then
    mode = Core.Gui.getInputMode()
  end

  -- Mode souris : le groupe survole devient actif via syncHoveredSelection().
  -- On ne dessine le feedback souris que sur le groupe actif, pour eviter
  -- deux contours actifs si plusieurs groupes visibles existent.
  if mode == "mouse" then
    if group.active and hovered then
      return hovered
    end

    if group.active and groupIsButtonSelectable(group, group.current) then
      return group.current
    end

    return nil
  end

  -- Mode clavier / manette : le hover souris ne vole pas le feedback.
  if group.active and groupIsButtonSelectable(group, group.current) then
    return group.current
  end

  return nil
end

local function groupDrawFocus(group, bt)
  if not bt or group.outlineVisible == false then
    return
  end

  local oldLineWidth = love.graphics.getLineWidth()
  local color = group.outlineColor or { 0, 1, 0, 1 }
  local width = group.outlineWidth or 2
  local padding = group.outlinePadding or 0
  local rounded = bt.rounded or 0

  love.graphics.setLineWidth(width)
  love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
  love.graphics.rectangle(
    "line",
    bt.x - padding,
    bt.y - padding,
    bt.w + padding * 2,
    bt.h + padding * 2,
    rounded,
    rounded
  )
  love.graphics.setLineWidth(oldLineWidth)
  love.graphics.setColor(1, 1, 1, 1)
end

local function groupSyncHoveredSelection(group)
  if group.visible == false or group.enabled == false then
    return false
  end

  local mode = "keyboard"

  if Core and Core.Gui and Core.Gui.getInputMode then
    mode = Core.Gui.getInputMode()
  end

  -- On synchronise la selection clavier/manette uniquement quand la souris
  -- est le dernier peripherique actif.
  -- Sinon, une souris posee sur un bouton volerait la selection pendant
  -- une navigation clavier/manette.
  if mode ~= "mouse" then
    return false
  end

  local hovered, hoveredIndex = group:getHovered()

  if not hovered or not hoveredIndex then
    return false
  end

  -- Le groupe survole devient le groupe actif.
  -- Comme ca, si on passe ensuite au clavier/manette,
  -- la navigation repart de ce groupe et de ce bouton.
  if Core and Core.Gui and Core.Gui.setActiveGroup then
    Core.Gui.setActiveGroup(group)
  else
    group.active = true
  end

  if group.current ~= hovered or group.selectedIndex ~= hoveredIndex then
    group:selectIndex(hoveredIndex)
  end

  return true
end

local function groupHandleInput(group)
  if group.visible == false or group.enabled == false or group.active ~= true then
    return false
  end

  if Core.Input.pressed("down") then
    group:selectNext()
  end

  if Core.Input.pressed("up") then
    group:selectPrevious()
  end

  if Core.Input.pressed("validate") then
    group:validate()
    return true
  end

  return false
end

local function groupUpdate(group, dt)
  if group.visible == false then
    group.hovered = nil
    group.visualCurrent = nil

    for n = 1, #group do
      group[n].visualActive = false
    end

    return group.current
  end

  if group.applyLayout then
    group:applyLayout()
  end

  for n = 1, #group do
    group[n]:update(dt)
  end

  if (not group.current or not groupIsButtonSelectable(group, group.current)) and #group > 0 then
    group:selectFirstAvailable()
  end

  group.hovered = group:getHovered()

  group:syncHoveredSelection()
  group:handleInput()

  group.visualCurrent = group:getVisualCurrent()

  for n = 1, #group do
    group[n].visualActive = group[n] == group.visualCurrent
  end

  return group.current
end

local function groupDraw(group)
  if group.visible == false then
    return
  end

  -- Recalcule au moment du draw pour eviter un feedback visuel stale
  -- si un autre groupe a pris le focus apres l'update de ce groupe.
  group.visualCurrent = group:getVisualCurrent()

  for n = 1, #group do
    group[n].visualActive = group[n] == group.visualCurrent
    group[n]:draw()
  end

  group:drawFocus(group.visualCurrent)
end

local function groupMousepressed(group, x, y, mouseButton, istouch, presses)
  if group.visible == false or group.enabled == false then
    return false
  end

  if mouseButton ~= 1 then
    return false
  end

  for n = 1, #group do
    local bt = group[n]

    if groupIsButtonSelectable(group, bt) and (bt.hovered or Core.Collision.aabbMouse(Core.Mouse, bt)) then
      if Core and Core.Gui and Core.Gui.setInputMode then
        Core.Gui.setInputMode("mouse", true)
      end

      if Core and Core.Gui and Core.Gui.setActiveGroup then
        Core.Gui.setActiveGroup(group)
      else
        group.active = true
      end

      group:selectIndex(n)
      group:validate()
      return true
    end
  end

  return false
end

local function groupKeypressed(group, k, s, isrepeat)
  return group:handleInput()
end

local function groupIsSelect(buttonObject, group)
  for n = 1, #group do
    local bt = group[n]

    if bt == buttonObject and groupIsButtonSelectable(group, bt) then
      group.selectedIndex = n
      group.current = bt
      bt.selected = true
    else
      bt.selected = false
    end
  end
end

local function groupSetVisible(group, visible)
  group.visible = visible ~= false

  if not group.visible then
    group.hovered = nil
    group.visualCurrent = nil

    for n = 1, #group do
      group[n].visualActive = false
    end

    if Core and Core.Gui and Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() == group then
      Core.Gui.clearActiveGroup(group)
    end
  end

  return group
end

local function groupSetEnabled(group, enabled)
  group.enabled = enabled ~= false

  if not group.enabled then
    group.hovered = nil
    group.visualCurrent = nil

    for n = 1, #group do
      group[n].visualActive = false
    end
  end

  return group
end

local function groupSetActive(group, active)
  if active == false then
    group.active = false

    if Core and Core.Gui and Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() == group then
      Core.Gui.clearActiveGroup(group)
    end

    return group
  end

  if Core and Core.Gui and Core.Gui.setActiveGroup then
    Core.Gui.setActiveGroup(group)
  else
    group.active = true
  end

  return group
end

local function groupSetLayout(group, config)
  if type(config) == "string" then
    config = { direction = config }
  end

  config = config or {}

  local direction = config.direction or config.orientation or config.axis or group.layoutDirection or "vertical"

  if direction ~= "horizontal" then
    direction = "vertical"
  end

  group.autoLayout = config.enabled ~= false
  group.layoutDirection = direction
  group.layoutX = config.x or group.layoutX or 0
  group.layoutY = config.y or group.layoutY or 0
  group.layoutW = config.w or group.layoutW
  group.layoutH = config.h or group.layoutH
  group.layoutAreaW = config.areaW or config.containerW or group.layoutAreaW
  group.layoutAreaH = config.areaH or config.containerH or group.layoutAreaH
  group.layoutSpacingAuto = config.spacing == "auto" or config.autoSpacing == true

  if type(config.spacing) == "number" then
    group.layoutSpacing = config.spacing
  elseif not group.layoutSpacing then
    group.layoutSpacing = 12
  end

  if group.applyLayout then
    group:applyLayout()
  end

  return group
end

local function groupLayoutVertical(group, x, y, spacing, w, h)
  return group:setLayout({
    direction = "vertical",
    x = x,
    y = y,
    spacing = spacing,
    w = w,
    h = h,
  })
end

local function groupLayoutHorizontal(group, x, y, spacing, w, h)
  return group:setLayout({
    direction = "horizontal",
    x = x,
    y = y,
    spacing = spacing,
    w = w,
    h = h,
  })
end

local function groupApplyLayout(group)
  if group.autoLayout ~= true then
    return group
  end

  local virtualW, virtualH = 1280, 720

  if Core and Core.getDimensions then
    virtualW, virtualH = Core.getDimensions()
  end

  local cursorX = group.layoutX or 0
  local cursorY = group.layoutY or 0
  local spacing = group.layoutSpacing or 0
  local visibleCount = 0
  local totalSize = 0

  if cursorX == "center" and group.layoutW then
    cursorX = (virtualW - group.layoutW) / 2
  elseif cursorX == "right" and group.layoutW then
    cursorX = virtualW - group.layoutW
  end

  if cursorY == "center" then
    local areaH = group.layoutAreaH or virtualH
    cursorY = (virtualH - areaH) / 2
  elseif cursorY == "bottom" then
    local areaH = group.layoutAreaH or virtualH
    cursorY = virtualH - areaH
  end

  for n = 1, #group do
    local bt = group[n]

    if bt.visible ~= false then
      visibleCount = visibleCount + 1

      if group.layoutDirection == "horizontal" then
        totalSize = totalSize + (group.layoutW or bt.w)
      else
        totalSize = totalSize + (group.layoutH or bt.h)
      end
    end
  end

  if group.layoutSpacingAuto and visibleCount > 1 then
    local areaSize = group.layoutDirection == "horizontal" and group.layoutAreaW or group.layoutAreaH

    if not areaSize then
      areaSize = group.layoutDirection == "horizontal" and virtualW or virtualH
    end

    spacing = math.max(0, (areaSize - totalSize) / (visibleCount - 1))
  end

  for n = 1, #group do
    local bt = group[n]

    if bt.visible ~= false then
      bt.x = cursorX
      bt.y = cursorY

      if group.layoutW then
        bt.w = group.layoutW
      end

      if group.layoutH then
        bt.h = group.layoutH
      end

      if group.layoutDirection == "horizontal" then
        cursorX = cursorX + bt.w + spacing
      else
        cursorY = cursorY + bt.h + spacing
      end
    end
  end

  return group
end

-- =========================================================
-- PUBLIC CONSTRUCTORS
-- =========================================================

function button.new(text, x, y, w, h, group, fct)
  local usedFont = love.graphics.getFont()

  local new = {
    name = text,
    font = usedFont,
    x = x,
    y = y,
    w = w,
    h = h,
    rounded = 15,
    rotate = 0,
    sx = 1,
    sy = 1,
    ox = 0,
    oy = 0,
    color = { 1, 1, 1, 1 },
    disabledColor = { 0.5, 0.5, 0.5, 1 },
    selected = false,
    hovered = false,
    visualActive = false,
    enabled = true,
    visible = true,
    textAlign = "center",
    textPadding = 12,

    isSelect = isSelect,
    isSelectable = isSelectable,
    load = load,
    update = update,
    draw = draw,
    mousepressed = mousepressed,
    keypressed = keypressed,
    getGroup = getGroup,
    setFunction = setFunction,
    onClick = onClick,
    setFont = setFont,
    setText = setText,
    setTextAlign = setTextAlign,
    setVisible = setVisible,
    setEnabled = setEnabled,
  }

  new.cx = new.w / 2
  new.cy = new.h / 2

  new.text = {
    data = love.graphics.newText(new.font, new.name),
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    ox = 0,
    oy = 0,
    color = { 0, 0, 0, 1 },
    colorSelect = { 0, 1, 0, 1 },
    colorDisabled = { 0.2, 0.2, 0.2, 1 },
    colorDefaut = { 0, 0, 0, 1 },
  }

  new.text.w, new.text.h = new.text.data:getDimensions()

  if type(fct) == "function" then
    new.fct = fct
    new.callback = fct
  else
    new.fct = function(self)
      print("button " .. tostring(new.name) .. " function does not exist. Use button:setFunction(function(self) ... end)")
    end
    new.callback = new.fct
  end

  if group then
    if type(group) == "table" then
      button.insert(group, new)
    elseif type(group) == "string" then
      button.insert(group, new)
    end
  else
    button.insert(button.ungrouped, new)
  end

  if new.group and new.group.applyLayout then
    new.group:applyLayout()
  end

  return new
end

function button.newGroup(name, layout)
  if button.lst_group[name] then
    if layout and button.lst_group[name].setLayout then
      button.lst_group[name]:setLayout(layout)
    end

    return button.lst_group[name]
  end

  button.lst_group[name] = {
    name = name,
    current = nil,
    hovered = nil,
    visualCurrent = nil,
    selectedIndex = 1,
    active = false,
    enabled = true,
    visible = true,
    autoLayout = false,
    layoutDirection = "vertical",
    layoutX = 0,
    layoutY = 0,
    layoutW = nil,
    layoutH = nil,
    layoutSpacing = 12,

    outlineColor = { 0, 1, 0, 1 },
    outlineWidth = 2,
    outlinePadding = 0,
    outlineVisible = true,

    load = groupLoad,
    update = groupUpdate,
    draw = groupDraw,
    mousepressed = groupMousepressed,
    keypressed = groupKeypressed,
    isSelect = groupIsSelect,

    selectIndex = groupSelectIndex,
    selectFirstAvailable = groupSelectFirstAvailable,
    selectNext = groupSelectNext,
    selectPrevious = groupSelectPrevious,
    validate = groupValidate,

    getHovered = groupGetHovered,
    getVisualCurrent = groupGetVisualCurrent,
    drawFocus = groupDrawFocus,
    handleInput = groupHandleInput,
    syncHoveredSelection = groupSyncHoveredSelection,

    setVisible = groupSetVisible,
    setEnabled = groupSetEnabled,
    setActive = groupSetActive,
    setLayout = groupSetLayout,
    layoutVertical = groupLayoutVertical,
    layoutHorizontal = groupLayoutHorizontal,
    applyLayout = groupApplyLayout,
  }

  if layout then
    button.lst_group[name]:setLayout(layout)
  end

  return button.lst_group[name]
end

function button.insert(groupName, bt)
  local gr = nil

  if type(groupName) == "string" then
    gr = button.lst_group[groupName]

    if not gr then
      gr = button.newGroup(groupName)
    end
  elseif type(groupName) == "table" then
    gr = groupName
  else
    print("bad argument with", groupName)
    print('You need create a group with "text variable" OR "group table" use before : button.newGroup(name)')
    return nil
  end

  for _, existingButton in ipairs(gr) do
    if existingButton == bt then
      bt.group = gr
      return gr
    end
  end

  local id = #gr + 1
  bt.id = id
  table.insert(gr, bt)
  bt.group = gr

  if gr.applyLayout then
    gr:applyLayout()
  end

  return gr
end

button.ungrouped = button.newGroup("unGrouped")

return button
