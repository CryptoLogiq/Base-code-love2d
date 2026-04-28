local corescene = {debug=true}

local lst_Scenes = {}

local current = nil

local function resolveScene(sceneOrName)
  if type(sceneOrName) == "string" then
    return corescene.GetScene(sceneOrName, false)
  end

  return sceneOrName
end

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
  local new = {name=name, loaded=false, entered=false}

  -- Important : on ne lance pas SetScene ici.
  -- La scène vient tout juste d'être créée, ses méthodes load/enter/update/draw
  -- ne sont pas encore déclarées par le fichier scene_xxx.lua.
  table.insert(lst_Scenes, new)

  if not current then
    current = new
  end

  if corescene.debug then
    print("scene created : "..new.name)
  end
  return new
end
--

function corescene.SetScene(sceneOrName)
  local scene = resolveScene(sceneOrName)

  if not scene then
    print('Scene variable is required for set a current Scene --> Core.Scene.SetScene("MySceneTable")')
    return
  end

  local previous = current

  -- Cas du premier lancement : current pointe déjà vers la première scène,
  -- mais elle n'a jamais reçu enter(). On ne considère donc pas ça comme
  -- une vraie transition depuis elle-même.
  if previous == scene and not scene.entered then
    previous = nil
  end

  if previous and previous ~= scene and previous.leave then
    previous.leave(scene)
    previous.entered = false
  end

  current = scene

  if scene.load and not scene.loaded then
    corescene.load(scene)
  end

  if scene.enter and not scene.entered then
    scene.enter(previous)
    scene.entered = true
  end

  if corescene.debug then
    print("Scene set to : " .. scene.name)
  end
end
--

function corescene.load(sceneOrName)
  local scene = resolveScene(sceneOrName)

  if scene then
    if scene.load and not scene.loaded then
      scene.load()
      scene.loaded = true

      if corescene.debug then
        print("Scene loaded : "..scene.name)
      end
    end

    return scene
  end

  if not current then
    current = lst_Scenes[1]
  end

  if current then
    corescene.SetScene(current)
  end

  return current
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

function corescene.keyreleased(k, s)
  if current and current.keyreleased then
    current.keyreleased(k, s)
  end
end
--

function corescene.mousereleased(x, y, button, istouch, presses)
  if current and current.mousereleased then
    current.mousereleased(x, y, button, istouch, presses)
  end
end
--

function corescene.gamepadpressed(joystick, button)
  if current and current.gamepadpressed then
    current.gamepadpressed(joystick, button)
  end
end
--

function corescene.gamepadreleased(joystick, button)
  if current and current.gamepadreleased then
    current.gamepadreleased(joystick, button)
  end
end
--

function corescene.gamepadaxis(joystick, axis, value)
  if current and current.gamepadaxis then
    current.gamepadaxis(joystick, axis, value)
  end
end
--

function corescene.joystickadded(joystick)
  if current and current.joystickadded then
    current.joystickadded(joystick)
  end
end
--

function corescene.joystickremoved(joystick)
  if current and current.joystickremoved then
    current.joystickremoved(joystick)
  end
end
--

return corescene
