lf = love.filesystem
ls = love.sound
la = love.audio
lp = love.physics
lt = love.thread
li = love.image
lg = love.graphics
ASTRING = "d"
test = {}
function love.load()
	matrix = require('matrix')
	require('enumerable')
	require('stack')
	require('color')
	require('rect')
	require('lovedebug')
	require('mathx')
	require('interpolation')
	require('coroutineManager')
	require('texture')
	require('mouse')
	require('keys')
	require('GUI')
	require('player')
	require('map')
	require('screen')
	require('tiles')
	require ('monocle')

	Monocle.new({
		filesToWatch = {
			'main.lua',
			'map.lua',
			'player.lua',
			'tiles.lua',
			'mathx.lua',
			'screen.lua'
		}
	})

	Mouse.init()
	Keys.init()
	Screen.init()
	CoroutineManager.init()
	Debug.init()

	Map.init()
	Player.init()

	test.line = matrix{0,0,1}:toXY()
	test.ray =  matrix{0,0,1}:toXY()

	box = GUI.window(
		Rect(25,25,100,100),
		{GUI.text("Hello world!", Rect(10,10,40,40))},
		{
			GUI.window.properties.resizable(10),
			GUI.window.properties.draggable
		}
	)
	Mouse.addLayer("GUI", function(pos) return box:capture(pos) end)
	GUI.debug()
end

iters = 10
function love.update()
	Monocle.update()

	dt = love.timer.getDelta()
	fps = love.timer.getFPS()

	Debug.update(dt)

	Player.update(dt)
	Keys.update()
	Mouse.update()
	Screen.update(dt)

	CoroutineManager.update()

	test.line = Screen.screenToWorldPosition(mousex, mousey)

	--[[local t = Screen.getTile(mousex, mousey)
	t.hit = true
	start = Screen.screenToWorldPosition(100,100)
	--for i = 1,iters*dt do
		test.ray = start+Map.rayCast(start, test.line-start)
	--end
	local pts = {}
	pts = mathx.supercover(start.x, start.y, test.line.x, test.line.y)
	for i = 1, #pts do
		local tile = Map.getTile(pts[i].x, pts[i].y)
		if tile.collides then break end
		--tile.hit = true
	end]]--
end

function love.draw()
	Screen.draw()
	Monocle.draw()
	--[[local l = Screen.worldToScreenPosition(test.ray.x, test.ray.y)
	love.graphics.setColor(255,0,255,255)
	love.graphics.line(100,100,l.x, l.y)
	love.graphics.setColor(255,255,0,255)
	--love.graphics.line(100,100,love.mouse.getPosition())
	local x, y = test.line.x, test.line.y
	love.graphics.print("iters:"..iters.." fps: "..fps)]]--

	Debug.draw(590, 0, 200, 403)
	box:draw()
end

function love.textinput(t)
    Monocle.textinput(t)
end
function love.keypressed(text)
    Monocle.keypressed(text)
    Keys.pressed(text)
end

function love.keyreleased(text)
    Keys.released(text)
end

function love.mousepressed(x,y,button)
	Mouse.pressed(x,y,button)
end

function love.mousereleased(x,y,button)
	Mouse.released(x,y,button)
end

function love.mousemoved(x,y,dx,dy)
	Mouse.moved(x,y,button)
end
