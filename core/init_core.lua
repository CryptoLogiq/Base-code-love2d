local f = "core/core_"

require(f.."maths")

--#########################
--### Core engine
--#########################
Core = require(f.."manager")

--#########################
--### Core modules
--#########################
Core.Gui = require(f.."gui")
Core.Timer = require(f.."timer")
Core.Mouse = require(f.."mouse")
Core.Scene = require(f.."scene")
Core.Collision = require(f.."collisions")