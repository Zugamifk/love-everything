Enumerable = {}
setmetatable(Enumerable, {
	__call = function(...) return Enumerable.New(...) end
})

function Enumerable:New(collection)
	if not collection then
		return setmetatable({}, {
			__index = Enumerable,
			__newindex = function(t,k,v)
				if Enumerable[k] then
					error("The key \'"..key.."\' is reserved in Enumerable!")
				else
					rawset(t,k,v)
				end
			end
		})
	end

	local mt = getmetatable(collection)
	return setmetatable(collection, setmetatable({
		__index = function(t,k)
			return mt and mt.__index and mt.__index(t,k) or Enumerable[k]
		end,
		--this prevents over writing functions in Enumerable
		__newindex = function(t,k,v)
			if Enumerable[k] then
				error("The key \'"..key.."\' is reserved in Enumerable!")
			else
				if mt and mt.__newindex then
					mt.__newindex(t,k,v)
				else
					rawset(t,k,v)
				end
			end
		end
	}, mt))
end

function Enumerable:Map(func)
	local new = setmetatable({}, getmetatable(self))
	for k,v in pairs(self) do
		new[k] = func(v)
	end
	return new
end

function Enumerable:iMap(func)
	local new = setmetatable({}, getmetatable(self))
	for k,v in pairs(self) do
		new[k] = func(k)
	end
	return new
end

function Enumerable:Filter(func)
	local new = setmetatable({}, getmetatable(self))
	for k,v in pairs(self) do
			if func(v) then
				new[k] = v
			end
	end
	return new
end

function Enumerable:iFilter(func)
	local new = setmetatable({}, getmetatable(self))
	for k,v in pairs(self) do
			if func(k) then
				new[k] = v
			end
	end
	return new
end

function Enumerable:Select(func)
	for k,v in pairs(self) do
		if func(v) then
			return v
		end
	end
end
