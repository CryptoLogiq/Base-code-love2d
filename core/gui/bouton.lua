
local bouton = {lst_group={}}

local function load()
end
--

local function update(dt)
end
--

local function draw()
end
--

local function mousepressed(x,y,button,istouch,presses)
end
--

local function keypressed(k,s,isrepeat)
end
--

function bouton.new(text, x, y, w, h, group)
  local new = {text=text, x=x, y=y, w=w, h=h, load=load, update=update, draw=draw, mousepressed=mousepressed, keypressed=keypressed}

  if group then
    bouton.addGroup(group, new)
  end
  return new
end
--

function bouton.newGroup(name)
  bouton.lst_group[name] = {}
end
--

function bouton.addGroupName(groupName, bt)
  if not bouton.lst_group.groupName then
    if type(groupName) == "text" then
      bouton.newGroup(groupName)
    else
      print('bad argument, you need create a group with "text variable", use before : bouton.newGroup(name)')
      return nil
    end
  end
  --
  local gr = bouton.lst_group[groupName]
  local id = #gr + 1
  bt.id = id
  table.insert(gr, bt)
end
--

return bouton