CoroutineManager = {}

function CoroutineManager.init()
-- shorter name
	local cm = CoroutineManager

	-- set up coroutine queue
	local queue_mt = {}
	cm.current = Enumerable(setmetatable({}, queue_mt))

end

function CoroutineManager.update()
	-- collect dead coroutines
	local dead = {}

	-- run coroutines
	for i,c in ipairs(CoroutineManager.current) do
		local err, msg = coroutine.resume(c.coroutine)
		if not err then
			error(msg)
		end
	end

	-- remove dead coroutines
	CoroutineManager.current = CoroutineManager.current:Filter(function(c) return coroutine.status(c.coroutine)~="dead" end)
end

function CoroutineManager.start(cr, time)
	cr = not time and cr
		or function()
			WaitForSeconds(time)
			cr()
		end

	-- direct assignment triggers __newindex, unlike table.insert... doh!
	local new = {
		coroutine = coroutine.create(cr)
	}
	table.insert(CoroutineManager.current, new)
end

-- globals
yield = coroutine.yield
StartCoroutine = CoroutineManager.start
WaitForSeconds = function(time)
	local start = love.timer.getTime()
	while love.timer.getTime() - start < time do
		yield()
	end
end
