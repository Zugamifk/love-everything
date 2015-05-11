Interpolation = {
	SinI = function(x)
		return math.sin(x*math.pi*0.5)
	end,
	SinO = function(x)
		return 1-math.sin(x*math.pi*0.5)
	end,
	SinIO = function(x)
		return 1-mathx.cosNP(x*0.5)
	end
}
setmetatable(Interpolation, {
	--returns a function that interpolates between two values 
	__call = function(_, lerp, start, finish) 
		if not start then
			return function(x) return lerp(x) end
		else
			return function(x) return start + (finish-start)*lerp(x) end
		end
	end
})