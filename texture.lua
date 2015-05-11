Texture = {}
local Texture_mt = {
    __call = function(...)
        return Texture.new(...)
    end

}
setmetatable(Texture, Texture_mt)

function Texture:new(width, height, fill, name)
    local texture = love.image.newImageData(width, height)
    texture:mapPixel(fill)
    texture:encode(name..".jpg")
end

function Texture:test()
    Texture(16,16,function() return Color.red:unpack() end, "test")
end
