local corescene = {debug=true}

local lst_Scenes = {}

local current = nil

function corescene.GetScene(name, new)
  if not name then return print('Scene Name is required for create a new scene --> Core.Scene.New("SceneName")') end
  --
  for k, scene in ipairs(lst_Scenes) do
    if scene.name == name then
      if new then
        print('Scene Name is already used, choice a other name')
      end
      if corescene.debug then
        print("scene found : "..scene.name)
      end
      return scene
    end
  end
  --
  return false
end
--

function corescene.New(name)
  local scn = corescene.GetScene(name, true)
  --
  if scn then
    return scn
  end
  --
  local new = {name=name, loaded=false}
  if #lst_Scenes <= 0 then corescene.SetScene(new) end
  table.insert(lst_Scenes, new)
  if corescene.debug then
    print("scene created : "..new.name)
  end
  return new
end
--

function corescene.SetScene(scene)
  if scene then
    current = scene
    if scene.load then
      if not scene.loaded then
        corescene.load(scene)
      end
    end
    
    if corescene.debug then
      print("Scene set to : "..scene.name)
    end
  else
    print('Scene variable is required for set a current Scene --> Core.Scene.SetScene("MySceneTable")')
  end
end
--

function corescene.load(scene)
  if not current then
    current = lst_Scenes[1]
  end
  --
  if current or scene then
    --
    if scene then
      scene.load()
      scene.loaded = true
    else
      current.load()
      current.loaded = true
    end
    if corescene.debug then
      print("Scene loaded : "..current.name)
    end
    --
  end
end
--

function corescene.update(dt)
  if current and current.update then
    current.update(dt)
  end
end
--

function corescene.draw()
  if current and current.draw then
    current.draw()

    if corescene.debug then
      love.graphics.print("Scene current running is : " .. current.name, 10, 10)
    end
  else
    love.graphics.print("Oops, no Scene is currently running", 10, 10)
  end
end
--

function corescene.mousepressed(x, y, button, istouch, presses)
  if current and current.mousepressed then
    current.mousepressed(x, y, button, istouch, presses)
  end
end
--

function corescene.keypressed(k, s, isrepeat)
  if current and current.keypressed then
    current.keypressed(k, s, isrepeat)
  end
end
--

return corescene
