local corescene = {debug=true}

local lst_Scenes = {}

local current = nil
local unpackColor = table.unpack or unpack

local function readBackgroundColor()
  if love and love.graphics and love.graphics.getBackgroundColor then
    return {love.graphics.getBackgroundColor()}
  end

  return {0, 0, 0, 1}
end

local function sameColor(a, b)
  if not a or not b then
    return false
  end

  local epsilon = 0.001
  return math.abs((a[1] or 0) - (b[1] or 0)) <= epsilon
    and math.abs((a[2] or 0) - (b[2] or 0)) <= epsilon
    and math.abs((a[3] or 0) - (b[3] or 0)) <= epsilon
    and math.abs((a[4] or 1) - (b[4] or 1)) <= epsilon
end

local function applyBackgroundColor(color)
  if color and love and love.graphics and love.graphics.setBackgroundColor then
    love.graphics.setBackgroundColor(unpackColor(color))
  end
end

local function resolveScene(sceneOrName)
  if type(sceneOrName) == "string" then
    return corescene.getScene(sceneOrName, false)
  end

  return sceneOrName
end

function corescene.getScene(name, new)
  if not name then return print('Scene name is required --> Core.Scene.new("SceneName")') end
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

function corescene.get(name, new)
  return corescene.getScene(name, new)
end

function corescene.new(name)
  local scn = corescene.getScene(name, true)
  --
  if scn then
    return scn
  end
  --
  local new = {name=name, loaded=false, entered=false, backgroundColor=nil}

  -- Important : on ne lance pas setScene ici.
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

function corescene.getCurrent()
  return current
end
--

function corescene.syncBackgroundColor(sceneOrName)
  local scene = resolveScene(sceneOrName) or current

  if not scene then
    return nil
  end

  local color = readBackgroundColor()

  if not sameColor(scene.backgroundColor, color) then
    scene.backgroundColor = color
  end

  return color[1], color[2], color[3], color[4]
end
--

function corescene.getBackgroundColor(sceneOrName)
  local scene = resolveScene(sceneOrName) or current

  if scene and scene.backgroundColor then
    return unpackColor(scene.backgroundColor)
  end

  return love.graphics.getBackgroundColor()
end
--

function corescene.setBackgroundColor(r, g, b, a, sceneOrName)
  local scene = resolveScene(sceneOrName) or current
  local color = type(r) == "table" and {r[1], r[2], r[3], r[4] or 1} or {r or 0, g or 0, b or 0, a or 1}

  if scene then
    scene.backgroundColor = color
  end

  if not sceneOrName or scene == current then
    applyBackgroundColor(color)
  end

  return color[1], color[2], color[3], color[4]
end
--

function corescene.applyBackgroundColor(sceneOrName)
  local scene = resolveScene(sceneOrName) or current

  if scene and scene.backgroundColor then
    applyBackgroundColor(scene.backgroundColor)
    return unpackColor(scene.backgroundColor)
  end

  return nil
end
--

function corescene.set(sceneOrName)
  local scene = resolveScene(sceneOrName)

  if not scene then
    print('Scene variable is required --> Core.Scene.set("MySceneTable")')
    return
  end

  local previous = current

  -- Cas du premier lancement : current pointe déjà vers la première scène,
  -- mais elle n'a jamais reçu enter(). On ne considère donc pas ça comme
  -- une vraie transition depuis elle-même.
  if previous == scene and not scene.entered then
    previous = nil
  end

  if previous and previous ~= scene then
    corescene.syncBackgroundColor(previous)
  end

  if previous and previous ~= scene and previous.leave then
    previous.leave(scene)
    previous.entered = false
  end

  current = scene

  corescene.applyBackgroundColor(scene)

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
    corescene.set(current)
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

function corescene.mousemoved(x, y, dx, dy, istouch)
  if current and current.mousemoved then
    current.mousemoved(x, y, dx, dy, istouch)
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
