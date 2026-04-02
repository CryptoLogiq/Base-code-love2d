local scene = {debug=true}

local lst_Scenes = {}

local current = nil

function scene.new(name)
  if not name then return print('Scene Name is required for create a new scene --> Scene.new("SceneName")') end
  local new = {name=name}
  if #lst_Scenes <= 0 then scene.setScene(new) end
  table.insert(lst_Scenes, new)
  return new
end
--

function scene.setScene(scene)
  if scene then
    current = scene
  else
    print('Scene variable is required for set a current Scene --> Scene.setScene("MySceneTable")')
  end
end
--

function scene.load(scene)
  if not current then
    current = lst_Scenes[1]
  end
  --
  if current or scene then
    --
    if scene then
      scene.load()
    else
      current.load()
    end
    --
  end
end
--

function scene.update(dt)
  -- Cores priority
  Mouse.update(dt)

  -- Scenes
  if current then
    current.update(dt)
  end
end
--

function scene.draw()
  -- Scenes
  if current then
    current.draw()
    if scene.debug then
      love.graphics.print("Scene current running is : "..current.name,10,10)
    end
  else
    love.graphics.print("Oops, no Scene is currently running, you need to create a scene",10,10)
  end

  -- Cores in end of draw for debug :
  Mouse.draw()
end
--

function scene.mousepressed(x,y,button,istouch,presses)
  if current then
    current.mousepressed(x,y,button,istouch,presses)
  end
end
--

function scene.keypressed(k,s,isrepeat)
  if current then
    current.keypressed(k,s,isrepeat)
  end
end
--

return scene
