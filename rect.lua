Rect = {}
Rect.mt = {
    __index = Rect,
    __tostring = function(r)
        return table.concat({"x: ", r.x, " y: ", r.y, " w: ", r.w, " h: ", r.h})
    end,
    __concat = function(a,v)
    	return tostring(a)..tostring(v)
    end
}
setmetatable(Rect, {
    __call = function(...) return Rect.new(...) end
})

function Rect:new(x,y,w,h)
    local r = {}
        r.x = x
        r.y = y
        r.w = w
        r.h = h
    return setmetatable(r, Rect.mt)
end

function Rect:unpack()
    return self.x, self.y, self.w, self.h
end

local function RectFactory(x,y,w,h)
    return function()
        return Rect(x,y,w,h)
    end
end
Rect.zero = RectFactory(0,0,0,0)
