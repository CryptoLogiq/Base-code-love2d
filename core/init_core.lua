local f = "core/core_"

require(f.."maths")

--#########################
--### Core engine
--#########################
Core = require(f.."manager")

--#########################
--### Core modules
--#########################
Core.Input = require(f.."input")
Core.Assets = require(f.."assets")
Core.Sprite = require(f.."sprite")
Core.Gui = require(f.."gui")
Core.Options = require(f.."options")
Core.Timer = require(f.."timer")
Core.Mouse = require(f.."mouse")
Core.Scene = require(f.."scene")
Core.Collision = require(f.."collisions")
