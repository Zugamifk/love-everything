-- A divider between two sections of an area, creating two new, smaller areas
GUI.partition = {}
GUI.partition.mt = {
    __call = function(gp, new)
        assert(new.orientation, "Partition requires an orientation of either 'horizontal' or 'veritcal'")
        assert(new.position, "Partition requires a position")
        -- capture in rect
        function new:capture(pos)
            return mathx.contains(pos, self.rect)
        end

        -- set draw based on orientation
        if new.orientation == "horizontal" then
            function new:draw()
                local r = self.rect
                lg.line(r.x, r.y+r.h/2, r.x+r.w, r.y+r.h/2)
            end
        elseif new.orientation == "vertical" then
            draw = function(self)
                local r = self.rect
                lg.line(r.x+r.w/2, r.y, r.x+r.w/2, r.y+r.h)
            end
        end
        new.orientation = orientation
        new.position = position
        new.cells = {}

        new = GUI.element{new}
        return setmetatable(new, {
            __index = GUI.partition,
            __call = function(self, partition)
              table.insert(self.cells, partition)
              return self
            end
        })
    end,
    __index = GUI.element
}
setmetatable(GUI.partition, GUI.partition.mt)
