-- Table for storing information for the screen
-- such as maop tiles
Screen = {

	-- dimensions of screen in pixels
	width = 0,
	height = 0,

	-- dimensions of screen in tiles
	grid_width = 48,
	grid_height = 32,

	-- position in map of the centre of the screen
	position = XY{ x = 24, y = 16 },

	-- dimensions of a tile
	tile_width = 0,
	tile_height = 0,

	-- tiles on screen
	tiles = {},

	--transformation matrix for screen-to-world and back
	matrixSTW = matrix(3,3,0),
	matrixWTS = matrix(3,3,1),

	--Screen targets
	targets = {
		default = {
			update = function() return XY.zero end,
			name = "default"
		}
	}
}

function Screen:init()
	-- get screen dimensions
	Screen.width, Screen.height = love.graphics.getDimensions()

	-- set tile dimensions based on screen dimensions
	Screen.tile_width = Screen.width/Screen.grid_width
	Screen.tile_height = Screen.height/Screen.grid_height

	-- initialize targets with default and new functions
	setmetatable(Screen.targets, {
		-- creates a new target
		__call = function(_,name, updateFunction, backRef)
		assert(updateFunction~=nil, name.." has no update!")
			local newTarget = {}
			newTarget.name = name
			newTarget.update = updateFunction
			newTarget.backReference = backRef
			Screen.targets[name] = newTarget
		end,
		__index = function() return Screen.targets.default end
	})

	--Track name of current target
	Debug.track(function() return "Target: "..Screen.targets.current.name end)
end

function Screen:update(dt)
	local gw = Screen.grid_width
	local gh = Screen.grid_height
	local tw = Screen.tile_width
	local th = Screen.tile_height

	-- update map grid position
	Screen.position = mathx.bound(Screen.targets.current.update(), XY(gw/2, Map.width-gw/2), XY(gh/2, Map.height-gh/2))

	-- update transformation matrix
	Screen.matrixSTW = matrix{
		{1/tw, 0, Screen.position.x-gw/2+1 },
		{0, -1/th, Screen.position.y + gh/2 +1},
		{0,0,1}}
	Screen.matrixWTS = Screen.matrixSTW^-1

	-- fetch tiles from map
	local x = Screen.position.x-Screen.grid_width/2
	local y = Screen.position.y-Screen.grid_height/2
	Screen.tiles = Map.getTiles(math.floor(x),math.floor(y),Screen.grid_width, Screen.grid_height)
end

function Screen:draw()
	local gw = Screen.grid_width
	local gh = Screen.grid_height
	local tw = Screen.tile_width
	local th = Screen.tile_height
	local _,ox = math.modf(Screen.position.x)
	local _,oy = math.modf(Screen.position.y)
	for x = 1,gw do
		for y= 1, gh do
			tile = Screen.tiles[x][y]
			tile.draw(
				(x-ox-1)*tw,
				(oy+gh-y)*th,
				tw,
				th
			)
			if tile.hit then
				Tiles.outline.draw((x-ox-1)*tw, (oy+gh-y)*th,tw, th)
			end
		end
	end
	Player.draw((Screen.grid_width/2)*tw,(gh-(Screen.grid_height/2))*th,tw,th)
end

function Screen.getTile(x,y)
	local pos = Screen.screenToWorldPosition(x,y)
	return Map.getTile(pos.x, pos.y)
end

function Screen.screenToWorldPosition(x,y)
	assert(x~=nil and y~=nil, "one of x or y is nil!")
	local pos = Screen.matrixSTW*matrix{x,y,1}
	return pos:toXY()
end

function Screen.worldToScreenPosition(x,y)
	local pos = Screen.matrixWTS*matrix{x,y,1}
	return pos:toXY()
end

function Screen.setTarget(target)
	Screen.targets.current = Screen.targets[target]
end
