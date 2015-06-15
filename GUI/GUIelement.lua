-- a base class for gui elements
GUI.element = {
    update = function(self, dt)
        self.anchor(self.rect)
    end,
    rect = Rect.zero(),
    anchor = GUI.anchor.custom(Rect.zero(), Rect.zero())
}
GUI.element.mt = {
    __call = function(ge, new)
        for k,v in pairs(GUI.element) do
            new[k] = new[k] or v
        end
        return setmetatable(new, {
            __index = GUI.defaults
        })
    end,
}
--TODO hahaha
setmetatable(GUI.element, GUI.element.mt)
