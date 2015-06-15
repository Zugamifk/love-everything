--text in a given area
GUI.text = {
}
GUI.text.mt = {
    __call = function(gt, new)
        assert(new.text, "GUI.text must be instantiated with text!")
        assert(new.rect, "GUI.text must be instantiated with a rect!")
        function new:draw()
            GUI.push(self.rect)
            GUI.colors.dark()
            lg.rectangle("fill", GUI.frame.x, GUI.frame.y, self.rect.w, self.rect.h)
            GUI.colors.text()
            lg.printf(new.text, GUI.frame.x, GUI.frame.y, self.rect.w, "left")
        end
        new.anchor = new.anchor or GUI.anchor.topcentre(new.rect)
        new = GUI.element(new)
        return setmetatable(new, {
            __index = GUI.text
        })
    end,
    __index = GUI.defaults
}
setmetatable(GUI.text, GUI.text.mt)
