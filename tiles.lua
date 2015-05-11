Tiles = {
	-- values
	width = 10,
	height = 10,
}

Tiles.air = {
	draw = function (_,_,_,_) end,
	collides = false
}

Tiles.ground = {
	draw = function(x,y,w,h)
		local ww, wh = love.graphics.getDimensions()
		love.graphics.setColor(255*x/ww, 255*y/wh, 0, 255) 
		love.graphics.rectangle("fill", x, y, w, h)
	end,
	collides = true,
	hit = false
}

Tiles.player = {
	draw = Player.draw,
	collides = true
}

Tiles.outline = {
	setColor = function(color) color = color end,
	color = {r = 255, g = 0, b = 0, a = 255 },
	draw = function(x,y,w,h) 
		c = Tiles.outline.color
		love.graphics.setColor(c.r, c.g, c.b, c.a) 
		love.graphics.rectangle("line", x, y, w, h)
	end
}