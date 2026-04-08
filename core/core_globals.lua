

-- bounding Box AABB :
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
--

-- AABB objects (x,y,w,h)
function AABB(a,b)
  return CheckCollision(a.x,a.y,a.w,a.h, b.x,b.y,b.w,b.h)
end
--


-- AABB mouse (x,y) vs object(x,y,w,h)
function AABB_Mouse(mouse, object)
  return CheckCollision(mouse.x,mouse.y,1,1, object.x,object.y,object.w,object.h)
end
--

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-- Distance between two 3D points:
function math.dist3D(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end

-- Returns the angle between two vectors assuming the same origin.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end


-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end


-- Linear interpolation between two numbers.
function lerp(a,b,t) return (1-t)*a + t*b end
function lerp2(a,b,t) return a+(b-a)*t end

-- Cosine interpolation between two numbers.
function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end


-- Normalize two numbers.
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end


-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


-- Randomly returns either -1 or 1.
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end


-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end


-- Gives a precise random decimal number given a minimum and maximum
function math.prandom(min, max) return love.math.random() * (max - min) + min end

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end

--


-- Checks if two lines intersect. If seg is true, the line is treated as a line segment. If ray is true, the line is treated as a ray originating at p1.
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1,seg2, ray1,ray2)
	ray1,ray2 = ray1 or seg1, ray2 or seg2

	local rx, ry = l1p2x - l1p1x, l1p2y - l1p1y
	local sx, sy = l2p2x - l2p1x, l2p2y - l2p1y
	local qpx, qpy = l2p1x - l1p1x, l2p1y - l1p1y

	local det = ( rx * sy - ry * sx )
	if det == 0 then return nil end -- The lines are parallel.

	local t = ( ( qpx ) * sy - ( qpy ) * sx ) / det
	local u = ( ( qpx ) * ry - ( qpy ) * rx ) / det
	if ( ray1 and t <= 0 ) or ( seg1 and t >= 1 ) or ( ray2 and u <= 0 ) or ( seg2 and u >= 1 ) then
		return nil -- The lines do not intersect
	end

	return l1p1x + t * rx, l1p1y + t * ry
end
--