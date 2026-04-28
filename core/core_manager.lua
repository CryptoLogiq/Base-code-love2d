local coremanager = {debug=true}


function coremanager.load()
    Core.Scene.load()
end
--

function coremanager.update(dt)
    -- Cores priority modules
    Core.Mouse.update(dt)

    -- Scene
    Core.Scene.update(dt)
end

function coremanager.draw()
    -- Scene
    Core.Scene.draw()

    -- Debug in end of draw for debug :
    Core.Mouse.draw()

end
--

function coremanager.mousepressed(x,y,button,istouch,presses)
    Core.Scene.mousepressed(x,y,button,istouch,presses)
end
--

function coremanager.keypressed(k,s,isrepeat)
    Core.Scene.keypressed(k,s,isrepeat)
end
--

return coremanager
