
local mouse = {x=0,y=0,w=1,h=1, debug=true}

function mouse.load()
end
--

function mouse.update(dt)
  mouse.x, mouse.y = love.mouse.getPosition()
end
--

function mouse.draw()
  if mouse.debug then
    love.graphics.setColor(1,0,0,1)
    love.graphics.circle("fill", mouse.x, mouse.y, 3)
    love.graphics.setColor(1,1,1,1)
  end
end
--

function mouse.mousepressed(x,y,button,istouch,presses)
end
--

return mouse