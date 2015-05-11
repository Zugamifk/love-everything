Debug = {
	messages = {
		maxDraw = 1
	},
	tracking = {
		-- fill with callbacks that return strings
	},

	-- draw settings
	GUIsettings = {
		logwindow = {
			edge = Color(0x3d, 0x89, 0xaf),
			fill = Color(0x71, 0xa8, 0xc1, 100),
			text = Color(0xdf, 0x48, 0x43),
			trackBack = Color(0x2c, 0x0d, 0x29, 100),
			trackText = Color(223,67,110, 255),
			size = 1,
			state = 1, -- -1 = closed, 0 = animating, 1 = open
			rect = Rect(0,0,0,0)
		}
	},

	-- camera settings
	camera = {
		position = XY.zero(),
		move = XY.zero(),
		speed = 15
	}
}

function Debug.init()
	Debug.messages.maxDraw = 50

	-- set up debug camera
	local mover = function(xy)
		return function()
			Debug.camera.move = Debug.camera.move  + xy*Debug.camera.speed
		end
	end
	local validDirections = {"left", "right", "up", "down"}
	for _,dir in ipairs(validDirections) do
		Keys.register(dir, mover(XY[dir]), "isDown", "Debug")
	end
	Screen.targets("Debug", function() return Debug.camera.position end, Debug.camera)

	--set up mouse grabbing
	Debug.GUIsettings.logwindow.edge:swap(Color(137,223,132,255))
	Debug.GUIsettings.logwindow.edge:swap()

	local logMouseCallback = function(state, event)
		local events = {
			enter = function(state)
				Debug.log("enter: "..Debug.GUIsettings.logwindow.edge)
				Debug.GUIsettings.logwindow.edge:swap()
			end,
			exit = function(state)
				Debug.log("exit: "..Debug.GUIsettings.logwindow.edge)
				Debug.GUIsettings.logwindow.edge:swap()
			end
		}
		local e = events[event]
		if e then e(state) end
	end
	Mouse.addLayer("Debug", function(pos)
		if mathx.contains(pos, Debug.GUIsettings.logwindow.rect) then
			return logMouseCallback
		end
	end)

	Debug.track(function() return "Position: "..Screen.position:int() end)
end

function Debug.draw(x,y,w,h)
	-- bg rectangle
	local settings = Debug.GUIsettings.logwindow
	local trackSpace = #Debug.tracking > 0 and (10+15*#Debug.tracking) or 0

	-- update gui data
	Debug.GUIsettings.logwindow.rect = Rect(x,y,w,h)

	-- for animations
	local trackSpacePercent = trackSpace/h
	local logPercent = math.max(settings.size-trackSpacePercent,0)
	local trackRealPercent = math.min(settings.size, trackSpacePercent)

	settings.fill()
	love.graphics.rectangle("fill", x, y, w, logPercent*h)

	settings.trackBack()
	love.graphics.rectangle("fill", x, y+logPercent*h, w, trackRealPercent*h)

	settings.edge()
	love.graphics.line(x, y+ logPercent*h, x+w,  y+ logPercent*h)
	love.graphics.rectangle("line", x, y, w, settings.size*h)

	-- draw message log
	local logsStart = y+logPercent*h
	settings.text()
	local maxMessages = math.min(#(Debug.messages), Debug.messages.maxDraw, logPercent*h/15)
	if maxMessages > 1 then
		for i = 1, maxMessages do
			if i==maxMessages then
				local _,a = math.modf(maxMessages)
				local fade = settings.text*a
				fade()
			end
			local message = Debug.messages[i]
			if type(message) == "function" then
				love.graphics.print(message(), x+5, logsStart-15*i)
			else
				love.graphics.print(message, x+5, logsStart-15*i)
			end
		end
	end

	--draw tracked values
	if #Debug.tracking > 0 then
		settings.trackText()
		for i = 1,math.min(#Debug.tracking,trackRealPercent*(h-10)/15) do
			local message = Debug.tracking[i]
			if type(message) == "function" then
				love.graphics.print(message(), x+5, logsStart+trackRealPercent*h-15*i-5)
			else
				love.graphics.print(message, x+5, logsStart+trackRealPercent*h-15*i-5)
			end
		end
	end

end

function Debug.update(dt)

	-- keep buffer empty
	if #(Debug.messages) > Debug.messages.maxDraw then
		for i = #Debug.messages, Debug.messages.maxDraw+1 do
			table.remove(Debug.messages, i)
		end
	end

	--update debug camera position
	Debug.camera.position = Debug.camera.position +Debug.camera.move*dt
	Debug.camera.move = XY.zero()
end


function Debug.log(message)
	table.insert(Debug.messages, 1, message)
end

function Debug.track(value)
	table.insert(Debug.tracking, value)
end

function Debug.printTable(t, name)
		Debug.log("Printing table"..(name and ": "..name or ""))
		for k,v in pairs(t) do
			Debug.log("\t"..k.."\t:\t"..v)
		end
end

--[[
	Animations for windows
]]
function Debug.Toggle()
	local anim = function()
		local start = Debug.GUIsettings.logwindow.state > 0 and 1 or 0
		local finish = 1-start
		local step = finish-start
		local move = Interpolation.SinIO
		Debug.GUIsettings.logwindow.state = 0
		for t=start, finish, dt*step do
			dt = love.timer.getDelta()
			Debug.GUIsettings.logwindow.size = move(t)
			yield()
		end
		Debug.GUIsettings.logwindow.state = finish - start
	end
	StartCoroutine(anim)
end
