--[[ COLORS.LUA
	Defines colors and methods for manipulating colors
	]]--
Color = {
	-- constants
	swapKey = "swapColorKey",
}
local Color_mt = {}

--controlled values
Color_proxy = {
	new = function(self, r,g,b,a)
		if type(r) == "table" then
			if getmetatable(r)==Color_mt then
				return setmetatable(
					{r=r.r, g=r.g, b=r.b, a=r.a},
					Color_mt
				)
			end
		end
		return setmetatable(
			{r=r, g=g, b=b, a=a or 255},
			Color_mt
		)
	end
}

-- metatable
setmetatable(Color, {
	__call = function(...) return Color_proxy.new(...) end,
	__index = function(t,k)
		local c = Color_proxy.palette
		return c[k] and Color(c[k]) or Color[k]
	end
})

Color_proxy.palette = {
	grey= setmetatable(Color(128,128,128,128),
		{__call = function(this,shade)
			return this*shade
		end}),
	white = Color(255,255,255,255),
	black = Color(0,0,0,255),
	clear = Color(0,0,0,0),
	red = Color(255,0,0,255),
	green = Color(0,255,0,255),
	blue = Color(0,0,255,255)
}

-- functions
function Color:CopyTo(to)
	to.r=self.r
	to.g=self.g
	to.b=self.b
	to.a=self.a
end

function Color:unpack()
	return self.r, self.g, self.b, self.a
end

function Color:swap(new)
	new = new or self[Color.swapKey]
	assert(new~=nil, "Can not swap with nil color!")
	self[Color.swapKey] = Color(self)
	new:CopyTo(self)
end

-- Metamethods
function Color_mt.__call(color)
	love.graphics.setColor(color.r, color.g, color.b, color.a)
end

Color_mt.__index = Color

function Color_mt.__add(a,b)
	return Color(a.r+b.r, a.g+b.g, a.b+b.b, a.a+b.a)
end

function Color_mt.__sub(a,b)
	return Color(a.r-b.r, a.g-b.g, a.b-b.b, a.a-b.a)
end

function Color_mt.__mul(a,b)
	if getmetatable(a)~=Color_mt then
		return Color(a*b.r, a*b.g, a*b.b, a*b.a)
	elseif getmetatable(b)~=Color_mt then
		return Color(a.r*b, a.g*b, a.b*b, a.a*b)
	else
		return Color(a.r*b.r, a.g*b.g, a.b*b.b, a.a*b.a)
	end
end

function Color_mt.__div(a,b)
	if getmetatable(a)~=Color_mt then
		return Color(a/b.r, a/b.g, a/b.b, a/b.a)
	elseif getmetatable(b)~=Color_mt then
		return Color(a.r/b, a.g/b, a.b/b, a.a/b)
	else
		return Color(a.r/b.r, a.g/b.g, a.b/b.b, a.a/b.a)
	end
end

function Color_mt.__tostring(col)
	local values = {"Color(", col.r, ", ", col.g, ", ", col.b, ", ", col.a, ")"}
	return table.concat(values)
end

function Color_mt.__concat(a,b)
	return tostring(a)..tostring(b)
end
