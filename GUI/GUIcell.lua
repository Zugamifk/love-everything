-- An area that can track input and contain elements
GUI.cell = {

    draw = function(self)
        GUI.push(self.rect)
        for _,v in ipairs(self.elements)do
            v:draw()
        end
        GUI.pop()
    end,
    capture = function(self, pos)
        if mathx.contains(pos, self.rect) then
            for _,e in pairs(self.elements) do
                local elementCB = e:capture(pos)
                if elementCB~=nil then
                    return elementCB
                end
            end
        end
    end,

    update = function(dt)
        for _,e in pairs(self.elements) do
            element:update(dt)
        end
    end,

    resize = function(self,w,h)
        self.rect.w = w
        self.rect.h = h

        for _,e in ipairs(self.elements) do
            e.anchor(e.rect, self.rect)
            e:resize(w,h)
        end
    end

}
--metatable
GUI.cell.mt = {
    __call = function(gc, new)
        assert(new.rect, "Cells must be defined by a Rect!")
        new.elements = new.elements or {}
        new.anchor = new.anchor or GUI.anchor.topleft(new.rect)
        new = GUI.element(new)
        return setmetatable(new, { __index = GUI.cell })
    end
}
setmetatable(GUI.cell, GUI.cell.mt)
