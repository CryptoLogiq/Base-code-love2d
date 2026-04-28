local Collision = {}

-- Rectangle overlap.
function Collision.check(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
--

-- Rect-like objects (x,y,w,h).
function Collision.aabb(a,b)
  return Collision.check(a.x,a.y,a.w,a.h, b.x,b.y,b.w,b.h)
end
--


-- Mouse point (x,y) vs rect-like object (x,y,w,h).
function Collision.aabbMouse(mouse, object)
  return Collision.check(mouse.x,mouse.y,1,1, object.x,object.y,object.w,object.h)
end
--

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function Collision.checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
--


-- Checks if two lines intersect. If seg is true, the line is treated as a line segment. If ray is true, the line is treated as a ray originating at p1.
-- Lines are given as four numbers (two coordinates)
function Collision.findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1,seg2, ray1,ray2)
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

return Collision
