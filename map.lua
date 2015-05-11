Map = {
	width = 1024,
	height = 256,
	tiles = {}
}

function Map.newTile(tileRef, x, y) 
	return setmetatable({x=x, y=y}, {__index = tileRef})
end

function Map:init()
	for x = 1,Map.width do
		Map.tiles[x] = {}
		for y= 1, Map.height do
			if math.sin(x/5)*10+math.sin(x)*5+10>y then
				Map.tiles[x][y] = Map.newTile(Tiles.ground,x,y)
			else
				Map.tiles[x][y] = Map.newTile(Tiles.air,x,y)
			end
		end
	end
end

function Map.rayCast(pos, ray) 
	local currentTile, lastTile
	local info = nil
	for pt in mathx.raycast(pos, ray) do
		info = pt
		currentTile = Map.getTile(pt.point.x, pt.point.y)
		if currentTile.collides then
			break
		end
		lastTile = currentTile
	end
	if lastTile == nil then
		-- handle being in a block!
		return {x=0, y=0}
	elseif lastTile == currentTile then
		-- no collisions!
		return ray
	else
		return ray:normalized()*info.distance
	end
end

Map.getTile = function(x,y)
	x = math.min(math.max(x, 1), Map.width)
	y = math.min(math.max(y, 1), Map.height)
	return Map.tiles[math.floor(x)][math.floor(y)]
end

Map.getTiles = function(x,y,w,h)
	tiles = {}
	
	tiles.x = math.min(math.max(x, 1), Map.width-w)
	tiles.y = math.min(math.max(y, 1), Map.height-h)
	
	for xi = 1,w do
		tiles[xi] = {}
		for yi= 1, h do
			tiles[xi][yi] = Map.tiles[tiles.x+xi][tiles.y+yi]
			-- test
			tiles[xi][yi].hit = false
		end
	end
	
	return tiles
end