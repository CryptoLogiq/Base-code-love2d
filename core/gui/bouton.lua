
local bouton = {lst_group={}}

local function load(self)
end
--

local function getGroup(self)
  return self.group
end
--

local function setFunction(self, fct)
  self.fct = fct
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
end
--

local function draw(self)
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.rounded)
  --
  local txt = self.text
  love.graphics.setColor(txt.color)
  love.graphics.draw(txt.data, txt.x, txt.y)
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

--## Boutons ## :

function bouton.new(text, x, y, w, h, group, font)
  local usedFont = font
  if not font then
    usedFont = love.graphics.getFont()
  end
  --
  local new = {textString=text, x=x, y=y, w=w, h=h, rounded=15, rotate=0, sx=1, sy=1, ox=0, oy=0, color={1,1,1,1}, load=load, update=update, draw=draw, getGroup=getGroup}
  new.cx = new.w/2
  new.cy = new.h/2
  --
  new.text = {data=love.graphics.newText(usedFont, new.textString),  x=0, y=0, w=0, h=0, ox=0, oy=0, color={0,0,0,1}, colorDefaut={0,0,0,1}}
  new.text.w,new.text.h = new.text.data:getDimensions()
  --
  new.fct = function(self) return print(new.textString, "function not exit") end
  --
  if group then
    if type(group) == "table" then
      new.group = group

    elseif type(group) == "string" then
      new.group = bouton.addGroupName(group, new)
    end
  end
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
  for n=1, #group do
    local bt = group[n]
    bt:update(dt)
  end
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
    if x >= bt.x and y >= bt.y and x <= bt.x + bt.w and y <= bt.y + bt.h then
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

function bouton.newGroup(name)
  bouton.lst_group[name] = {load=groupLoad, update=groupUpdate, draw=groupDraw, mousepressed=groupMousepressed, keypressed=groupKeypressed}
  return bouton.lst_group[name]
end
--

function bouton.addGroupName(groupName, bt)
  local groupExist = false
  local gr = nil
  --
  if not bouton.lst_group.groupName then

    if type(groupName) == "string" then

      if bouton.lst_group[groupName] then
        gr = bouton.lst_group[groupName]
      else
        gr = bouton.newGroup(groupName)
      end
      groupExist = true

    elseif type(groupName) == "table" then

      for index, groups in pairs(bouton.lst_group) do
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
    print('You need create a group with "text variable" OR "group table" use before : bouton.newGroup(name)')
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

return bouton