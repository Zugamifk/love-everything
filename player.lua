-- Global reference table
Player = {
	-- world position
	position = XY(50,30),
	
	-- size in world units
	dimensions = { w = 2, h = 3 },
	
	-- A callback function for drawing, by default ar ed box
	draw = function(x,y,w,h)
		love.graphics.setColor(255, 0, 0, 255) 
		love.graphics.rectangle("line", x, y-h*Player.dimensions.h, w*Player.dimensions.w, h*Player.dimensions.h)
		local to = Screen.worldToScreenPosition(Player.position+Player.velocity)
		love.graphics.line(x, y, to.x, to.y)
		love.graphics.print("pos: "..tostring(Player.velocity), 10, 15)
	end,
	
	-- current physical properties
	velocity = XY(0,0),
	moved = false,
	
	-- Move callback, for player input
	move = function(move)
		Player.velocity = Player.velocity  + XY(
			move.x,
			move.y
		)
		Player.moved = true
		Player.moveVector = XY(0,0)
	end
}

-- called once a frame
function Player.update(dt)
	
	Player.move(Player.moveVector)
	step = Player.velocity*dt
	Player.position = Player.position + Map.rayCast(Player.position, Player.velocity*dt)
	Player.velocity = Player.velocity
	--Debug.log("Player velocity: "..Player.velocity)
end

-- initializer
function Player:init() 
	-- initalize velocity
	Player.velocity=XY(0,0)
	
	Monocle.watch("Position", function () return Player.position.x..", "..Player.position.y end)
	
	-- Set up arrow key press callbacks for movement
	Player.moveVector = XY(0,0)
	Keys.setFrame("Player") 
	local mover = function(xy) 
		return function() 
			Player.moveVector = Player.moveVector + xy 
		end 
	end
	local validDirections = {"left", "right", "up", "down"}
	for _,dir in ipairs(validDirections) do
		Keys.register(dir, mover(XY[dir]), "isDown")
	end
	
	-- Track with camera
	Screen.targets("Player", function() return Player.position end, Player)
	Screen.setTarget("Player")
end

