local page = {}

local function addGroup(self, name, group)
  if not group then
    group = name
    name = group and group.name
  end

  if not group then
    return nil
  end

  name = name or group.name or tostring(#self.groups + 1)

  self.groups[name] = group
  table.insert(self.order, group)

  return group
end

local function getGroup(self, name)
  return self.groups[name]
end

local function setActiveGroup(self, groupOrName)
  local group = groupOrName

  if type(groupOrName) == "string" then
    group = self.groups[groupOrName]
  end

  if group and Core and Core.Gui and Core.Gui.setActiveGroup then
    Core.Gui.setActiveGroup(group)
  end

  self.activeGroup = group
  return group
end

local function show(self)
  self.visible = true
  return self
end

local function hide(self)
  self.visible = false

  if Core and Core.Gui and Core.Gui.getActiveGroup then
    local active = Core.Gui.getActiveGroup()

    for _, group in ipairs(self.order) do
      if active == group then
        Core.Gui.clearActiveGroup(group)
        break
      end
    end
  end

  return self
end

local function setVisible(self, visible)
  if visible == false then
    return self:hide()
  end

  return self:show()
end

local function setEnabled(self, enabled)
  self.enabled = enabled ~= false
  return self
end

local function setGroupVisible(self, name, visible)
  local group = self.groups[name]

  if group and group.setVisible then
    group:setVisible(visible)
  elseif group then
    group.visible = visible ~= false
  end

  if group and visible == false and Core and Core.Gui and Core.Gui.getActiveGroup and Core.Gui.getActiveGroup() == group then
    Core.Gui.clearActiveGroup(group)
  end

  return group
end

local function setOnlyGroupVisible(self, name)
  local target = nil

  for groupName, group in pairs(self.groups) do
    local visible = groupName == name

    if group.setVisible then
      group:setVisible(visible)
    else
      group.visible = visible
    end

    if visible then
      target = group
    end
  end

  return target
end

local function update(self, dt)
  if not self.visible then
    return
  end

  for _, group in ipairs(self.order) do
    if group.update then
      group:update(dt)
    end
  end
end

local function draw(self)
  if not self.visible then
    return
  end

  for _, group in ipairs(self.order) do
    if group.draw then
      group:draw()
    end
  end
end

local function mousepressed(self, x, y, button, istouch, presses)
  if not self.visible or not self.enabled then
    return false
  end

  -- On parcourt à l'envers pour donner la priorité aux groupes dessinés en dernier.
  for i = #self.order, 1, -1 do
    local group = self.order[i]

    if group.mousepressed and group:mousepressed(x, y, button, istouch, presses) then
      return true
    end
  end

  return false
end

function page.new(name)
  return {
    name = name or "Page",
    visible = true,
    enabled = true,
    groups = {},
    order = {},
    activeGroup = nil,

    addGroup = addGroup,
    getGroup = getGroup,
    setActiveGroup = setActiveGroup,
    show = show,
    hide = hide,
    setVisible = setVisible,
    setEnabled = setEnabled,
    setGroupVisible = setGroupVisible,
    setOnlyGroupVisible = setOnlyGroupVisible,
    update = update,
    draw = draw,
    mousepressed = mousepressed,
  }
end

return page
