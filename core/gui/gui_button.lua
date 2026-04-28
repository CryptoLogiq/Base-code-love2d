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
  end

  return self
end

local function setEnabled(self, enabled)
  self.enabled = enabled ~= false

  if not self.enabled then
    self.hovered = false
    self.selected = false
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
  txt.x = self.cx - txt.ox
  txt.y = self.cy - txt.oy

  if self.enabled == false then
    self.hovered = false
    return
  end

  self.hovered = Core.Collision.AABB_Mouse(Core.Mouse, self)
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
  elseif self.selected or self.hovered then
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
  if group.visible == false then
    return nil
  end

  local hovered = group:getHovered()

  if hovered then
    return hovered
  end

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
    return group.current
  end

  for n = 1, #group do
    group[n]:update(dt)
  end

  if not group.current and #group > 0 then
    group:selectFirstAvailable()
  end

  group.hovered = group:getHovered()
  group.visualCurrent = group:getVisualCurrent()

  group:handleInput()

  return group.current
end

local function groupDraw(group)
  if group.visible == false then
    return
  end

  for n = 1, #group do
    group[n]:draw()
  end

  group:drawFocus(group:getVisualCurrent())
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

    if groupIsButtonSelectable(group, bt) and (bt.hovered or Core.Collision.AABB_Mouse(Core.Mouse, bt)) then
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
    enabled = true,
    visible = true,

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
      button.addGroupName(group, new)
    elseif type(group) == "string" then
      button.addGroupName(group, new)
    end
  else
    button.addGroupName(button.ungrouped, new)
  end

  return new
end

function button.newGroup(name)
  if button.lst_group[name] then
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

    setVisible = groupSetVisible,
    setEnabled = groupSetEnabled,
    setActive = groupSetActive,
  }

  return button.lst_group[name]
end

function button.addGroupName(groupName, bt)
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

  return gr
end

button.ungrouped = button.newGroup("unGrouped")

return button
