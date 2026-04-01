local timer = {}

local function update(self, dt)
  if self.paused then return false end
  --
  self.current = self.current + (self.speed * dt)
  if self.current >= self.delai then
    self.current = 0
    return true
  else
    return false
  end
end
--

local function draw(self, x, y)
  local current = tostring( math.floor( self.current) )
  local delai = tostring( self.delai )
  --
  local txt = "timer : "..current.."/"..delai
  --
  love.graphics.print(txt, x or 10, y or 10)
end
--

local function pause(self)
  self.paused = not self.paused
end
--

local function stop(self)
  self.paused = true
  self.current = 0
end
--

local function play(self)
  self.paused = false
end
--

local function restart(self)
  self.current = 0
end
--

function timer.new(delai)
  local newT = {
    
    -- vars
    delai=delai or 10,
    speed=60,
    current=0,
    paused=false,
    
    -- functions
    update=update,
    draw=draw,
    pause=pause,
    stop=stop,
    play=play,
    resume=play,
    restart=restart
    
  }

  return newT
end
--

return timer