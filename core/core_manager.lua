local Core = {}

function Core.load()
    Core.Input.load()

    if Core.Gui and Core.Gui.load then
        Core.Gui.load()
    end
    
    if Core.Scene.load then
        Core.Scene.load()
    end
end

function Core.update(dt)
    Core.Input.update(dt)

    if Core.Gui and Core.Gui.update then
        Core.Gui.update(dt)
    end
    
    if Core.Mouse.update then
        Core.Mouse.update(dt)
    end
    
    if Core.Scene.update then
        Core.Scene.update(dt)
    end
    
    Core.Input.clearFrame()
end

function Core.draw()
    if Core.Gui and Core.Gui.draw then
        Core.Gui.draw()
    end

    if Core.Scene.draw then
        Core.Scene.draw()
    end
    
    if Core.Mouse.draw then
        Core.Mouse.draw()
    end
end

function Core.keypressed(key, scancode, isrepeat)
    Core.Input.keypressed(key, scancode, isrepeat)
    
    if Core.Scene.keypressed then
        Core.Scene.keypressed(key, scancode, isrepeat)
    end
end

function Core.keyreleased(key, scancode)
    Core.Input.keyreleased(key, scancode)
    
    if Core.Scene.keyreleased then
        Core.Scene.keyreleased(key, scancode)
    end
end

function Core.mousepressed(x, y, button, istouch, presses)
    Core.Input.mousepressed(x, y, button, istouch, presses)
    
    if Core.Scene.mousepressed then
        Core.Scene.mousepressed(x, y, button, istouch, presses)
    end
end

function Core.mousereleased(x, y, button, istouch, presses)
    Core.Input.mousereleased(x, y, button, istouch, presses)
    
    if Core.Scene.mousereleased then
        Core.Scene.mousereleased(x, y, button, istouch, presses)
    end
end

function Core.gamepadpressed(joystick, button)
    Core.Input.gamepadpressed(joystick, button)
    
    if Core.Scene.gamepadpressed then
        Core.Scene.gamepadpressed(joystick, button)
    end
end

function Core.gamepadreleased(joystick, button)
    Core.Input.gamepadreleased(joystick, button)
    
    if Core.Scene.gamepadreleased then
        Core.Scene.gamepadreleased(joystick, button)
    end
end

function Core.gamepadaxis(joystick, axis, value)
    Core.Input.gamepadaxis(joystick, axis, value)
    
    if Core.Scene.gamepadaxis then
        Core.Scene.gamepadaxis(joystick, axis, value)
    end
end

function Core.joystickadded(joystick)
    Core.Input.joystickadded(joystick)
    
    if Core.Scene.joystickadded then
        Core.Scene.joystickadded(joystick)
    end
end

function Core.joystickremoved(joystick)
    Core.Input.joystickremoved(joystick)
    
    if Core.Scene.joystickremoved then
        Core.Scene.joystickremoved(joystick)
    end
end

return Core
