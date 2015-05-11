Keys = {
	frames = {
		default = {
			isDown = {},
			pressed = {},
			released = {}
		}
	}
}

function Keys.newFrame() 
	local default = function(ct)
		return setmetatable({}, {__index = Keys.frames.default[ct]})
	end
	return {
			isDown = default("isDown"),
			pressed = default("pressed"),
			released = default("released")
		}
end

function Keys.init() 
	-- set the frame "default" to the table initialized for currentFrame
	Keys.currentFrame = Keys.frames.default
	
	--absent frames will be initialized
	frames_mt = {
		__index = function(t, k)
			t[k] = Keys.newFrame()
			Debug.log("New frame! "..k)
			return setmetatable(t[k], {})
		end
	}
	setmetatable(Keys.frames, frames_mt)
	
	-- setup global keys
	Keys.registerDefault(
		"f1",
		function() 
			Keys.setFrame("Debug") 
			Screen.setTarget("Debug")
			Debug.log("Setting frame to \'Debug\'")
		end,
		"released"
	)
	Keys.registerDefault(
		"f2",
		function() 
			Keys.setFrame("Player") 
			Screen.setTarget("Player")
			Debug.log("Setting frame to \'Player\'")
		end,
		"released"
	)
	Keys.registerDefault(
		"escape",
		function() 
			love.event.quit()
		end,
		"released"
	)
	Keys.registerDefault(
		"`",
		Debug.Toggle,
		"released"
	)
end

function Keys.update() 
	for k, v in pairs(Keys.currentFrame.isDown) do
		if love.keyboard.isDown(k) then
			v()
		end
	end
end

function Keys.pressed(key)
	if Keys.currentFrame.pressed[key] then 
		Keys.currentFrame.pressed[key]()
	end
end

function Keys.released(key)
	if Keys.currentFrame.released[key] then 
		Keys.currentFrame.released[key]()
	end
end

function Keys.register(key, action, context, frame)
	assert(key, "Must supply a key to register!")
	assert(action, "\'"..key.."\' must be supplied an action to register!")
	assert(context, "\'"..key.."\' must be supplied a context to register!")
	frame = frame and Keys.frames[frame] or Keys.currentFrame
	frame[context][key] = action
end

function Keys.registerDefault(key, action, context)
	assert(key, "Must supply a key to register!")
	assert(action, "\'"..key.."\' must be supplied an action to register!")
	assert(context, "\'"..key.."\' must be supplied a context to register!")
	Keys.frames.default[context][key] = action
end

function Keys.setFrame(frame)
	Keys.currentFrame = Keys.frames[frame]
end