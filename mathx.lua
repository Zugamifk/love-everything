mathx = {
	supercover = function (x1, y1, x2, y2)
		  local points = {}
		  local xstep, ystep, err, errprev, ddx, ddy
		  local e = matrix{x=0,y=0}
		  local x, y=0,0
		  local dx, dy = x2 - x1, y2 - y1
		x, e.x = math.modf(x1)
		y, e.y = math.modf(y1)

		  points[#points + 1] = {x = x1, y = y1}

		  if dy < 0 then
		    ystep = -1
		    dy = -dy
		  else
		    ystep = 1
		  end

		  if dx < 0 then
		    xstep = -1
		    dx = -dx
		  else
		    xstep = 1
		  end

		  ddx, ddy = dx * 2, dy * 2

		  if ddx >= ddy then
		    errprev, err = dx, dx
		    for i = 1, dx do
		      x = x + xstep
		      err = err + ddy
		      if err > ddx then
			y = y + ystep
			err = err - ddx
			if err + errprev < ddx then
			  points[#points + 1] = {x = x, y = y - ystep}
			elseif err + errprev > ddx then
			  points[#points + 1] = {x = x - xstep, y = y}
			else
			  points[#points + 1] = {x = x, y = y - ystep}
			  points[#points + 1] = {x = x - xstep, y = y}
			end
		      end
		      points[#points + 1] = {x = x, y = y}
		      errprev = err
		    end
		  else
		    errprev, err = dy, dy
		    for i = 1, dy do
		      y = y + ystep
		      err = err + ddx
		      if err > ddy then
			x = x + xstep
			err = err - ddy
			if err + errprev < ddy then
			  points[#points + 1] = {x = x - xstep, y = y}
			elseif err + errprev > ddy then
			  points[#points + 1] = {x = x, y = y - ystep}
			else
			  points[#points + 1] = {x = x, y = y - ystep}
			  points[#points + 1] = {x = x - xstep, y = y}
			end
		      end
		      points[#points + 1] = {x = x, y = y}
		      errprev = err
		    end
		  end
		  return points
	end,

	--some trig stuff
	sinN = function(x)
		return math.sin(x*math.pi*2)
	end,
	sinP = function(x)
		return math.sin(x)*0.5+0.5
	end,
	sinNP = function(x)
		return math.sin(x*math.pi*2)*0.5+0.5
	end,
	cosN = function(x)
		return math.cos(x*math.pi*2)
	end,
	cosP = function(x)
		return math.cos(x)*0.5+0.5
	end,
	cosNP = function(x)
		return math.cos(x*math.pi*2)*0.5+0.5
	end,

	-- Geometry stuff
	contains = function(pos, bounds)
		return pos.x >= bounds.x and
			pos.x <= bounds.x + bounds.w and
			pos.y >= bounds.y and
			pos.y <= bounds.y + bounds.h
	end,

	-- number stuff
	clamp = function(value, min, max)
		return math.max(math.min(max, value), min)
	end,
	bound = function(xy, horz, vert)
		return XY(mathx.clamp(xy.x, horz.x, horz.y), mathx.clamp(xy.y, vert.x, vert.y))
	end
}

function mathx.raycast(pos, ray)
	local x, y = math.floor(pos.x), math.floor(pos.y)
	local toX, toY = math.huge, math.huge

	local dx,dy = math.huge, math.huge
	local sx, sy = 0,0

	local dmax = math.sqrt(ray.x^2+ray.y^2)

	if(ray.x ~= 0)  then
		dx = math.sqrt(1+ray.y^2/ray.x^2)
		if ray.x < 0 then
			sx = -1
			toX = (pos.x-x)*dx
		else
			sx = 1
			toX = (x+1-pos.x)*dx
		end
	end
	if(ray.y ~= 0)  then
		dy = math.sqrt(1+ray.x^2/ray.y^2)
		if ray.y < 0 then
			sy = -1
			toY = (pos.y-y)*dy
		else
			sy = 1
			toY = (y+1-pos.y)*dy
		end
	end

	local pts = {}
	local dist = 0
	function iter()
		if toX < dmax or toY < dmax then
			if toX < toY then
				dist = toX
				toX = toX + dx
				x = x + sx
				pts[#pts+1]=XY(x,y)
			elseif toX>toY then
				dist = toY
				toY = toY + dy
				y = y + sy
				pts[#pts+1]=XY(x,y)
			else
				dist = toX
				toY = toY + dy
				y = y + sx
				pts[#pts+1]=XY(x,y)
				toX = toX + dx
				x = x + sx
				pts[#pts+1]=XY(x,y)
			end
			return {point=pts[#pts], distance = dist, hit = dist < dmax}
		end
		return nil
	end
	return iter, nil, nil
end
