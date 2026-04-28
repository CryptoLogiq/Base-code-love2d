
local button = {lst_group={}, debug=true}

local function load(self)
end
--

local function getGroup(self)
  return self.group or false
end
--

local function setFunction(self, fct)
  self.fct = fct
end
--

local function setFont(self, font)
  self.font = font
  self.text.data=love.graphics.newText(font, self.name)
  self.text.w, self.text.h = self.text.data:getDimensions()
end
--


local function setText(self, text, font)
  self.name = text
  self.text.data=love.graphics.newText(font or self.font, self.name)
  self.text.w, self.text.h = self.text.data:getDimensions()
end
--

local function update(self, dt)
  self.cx = self.x + self.w/2
  self.cy = self.y + self.h/2
  --
  self.oy = 0 - (self.h/2)
  --
  local txt = self.text
  txt.ox = txt.w/2
  txt.oy = txt.h/2
  txt.x = self.cx - txt.ox
  txt.y = self.cy - txt.oy

  -- Mouse on button ? if yes selected this button :
  if Core.Collision.AABB_Mouse(Core.Mouse, self) then
    self:isSelect(self)
  else
    self.selected = false
  end
end
--

local function draw(self)
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.rounded)
  --
  local txt = self.text
  if self.selected then
    love.graphics.setColor(txt.colorSelect)
  else
    love.graphics.setColor(txt.color)
  end
  love.graphics.draw(txt.data, txt.x, txt.y)
  --
  love.graphics.setColor(1,1,1,1)
end
--

local function isSelect(self)
  if self.group then
    self.group.isSelect(self, self.group)
  else
    self.selected = true
  end
end
--

local function mousepressed(self)
  if self.fct then
    self:fct()
  end
end
--

local function keypressed(self)
  if self.fct then
    self.fct(self)
  end
end
--

--## buttons ## :

function button.new(text, x, y, w, h, group, fct)

  local new = {name=text, x=x, y=y, w=w, h=h, rounded=15, rotate=0, sx=1, sy=1, ox=0, oy=0, color={1,1,1,1}, selected=false, isSelect=isSelect,  load=load, update=update, draw=draw, getGroup=getGroup, setFunction=setFunction, setFont=setFont, setText=setText}
  new.cx = new.w/2
  new.cy = new.h/2
  --
  local  usedFont = love.graphics.getFont()
  new.text = {data=love.graphics.newText(usedFont, new.name),  x=0, y=0, w=0, h=0, ox=0, oy=0, color={0,0,0,1}, colorSelect={0,1,0,1}, colorDefaut={0,0,0,1}}
  new.text.w,new.text.h = new.text.data:getDimensions()
  --
  if not fct then
    new.fct = function(self) return print("button "..new.name, "function not exit, use   button:setFunction( function(self) 'core function' end)") end
  else
    if type(fct) == "function" then
      new.fct = fct
    else
      new.fct = function(self) print("\n".."button "..new.name, "bads arguments to create function for button, use :  function(self) 'core function' end".."\n".."follow this example :".."\n"..'quit = Gui.button.new("Quit", 150, 500, 500, 50, "Menu", function(self) love.event.quit() end)'.."\n") end
      new.fct()
    end
  end
  --
  if group then
    if type(group) == "table" then
      new.group = group

    elseif type(group) == "string" then
      new.group = button.addGroupName(group, new)
    end
  else
    new.group = button.ungrouped
  end
  --
  return new
end
--

-- ## Groups ## --

local function groupLoad(group)
  for n=1, #group do
    local bt = group[n]
    bt:load()
  end
end
--

local function groupUpdate(group, dt)
  local current_bt = false
  for n=1, #group do
    local bt = group[n]
    bt:update(dt)
    if bt.selected then
      current_bt = bt
    end
  end
  if not current_bt then
  end
  return current_bt
end
--

local function groupDraw(group)
  for n=1, #group do
    local bt = group[n]
    bt:draw()
  end
end
--

local function groupMousepressed(group, x,y,button,istouch,presses)
  for n=1, #group do
    local bt = group[n]
    if Core.Collision.AABB_Mouse(Core.Mouse, bt) then
      bt:isSelect()
      bt:fct()
      break
    end
  end
end
--

local function groupKeypressed(group, k,s,isrepeat)
  for n=1, #group do
    local bt = group[n]
  end
end
--

local function groupIsSelect(button, group)
  for n=1, #group do
    local bt = group[n]
    if bt ~= button then
      bt.selected = false
    else
      bt.selected = true
    end
  end
end
--

function button.newGroup(name)
  button.lst_group[name] = {load=groupLoad, update=groupUpdate, draw=groupDraw, mousepressed=groupMousepressed, keypressed=groupKeypressed, isSelect=groupIsSelect}
  return button.lst_group[name]
end
--

function button.addGroupName(groupName, bt)
  local groupExist = false
  local gr = {}
  --
  if not button.lst_group.groupName then

    if type(groupName) == "string" then

      if button.lst_group[groupName] then
        gr = button.lst_group[groupName]
      else
        gr = button.newGroup(groupName)
      end
      groupExist = true

    elseif type(groupName) == "table" then

      for index, groups in pairs(button.lst_group) do
        if groupName == groups then
          gr = groups
          groupExist = true
          break
        end
      end

    end

  end
  --
  if not groupExist then
    print('bad argument with', groupName)
    print('You need create a group with "text variable" OR "group table" use before : button.newGroup(name)')
    return nil
  end
  --
  local id = #gr + 1
  bt.id = id
  table.insert(gr, bt)
  bt.group = gr
  return gr
end
--

button.ungrouped = button.newGroup("unGrouped")

return button