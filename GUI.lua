--[[
    GUI
    Defines some functions for use in input callbacks, will construct and draw
    gui elements

]]
GUI = {
    colors = {
        border = Color(50,48,62),
        background = Color(168,168,114),
        text = Color(45,21,55),
        text2 = Color(117,22,44),
        dark = Color(99,109,72)
    },

    defaults = {
        capture = function() end,
        draw = function() end,
        resize = function() end
    },

    stack = Stack(),
    frame = XY.zero(),
    push = function(rect)
        GUI.stack:Push(rect)
        GUI.frame.x=GUI.frame.x+rect.x
        GUI.frame.y=GUI.frame.y+rect.y
    end,
    pop = function()
        local r = GUI.stack:Pop()
        if r then
            GUI.frame.x=GUI.frame.x-r.x
            GUI.frame.y=GUI.frame.y-r.y
        end
    end,
    clear = function()
        GUI.stack:Clear()
        GUI.frame = XY.zero()
    end
}

local guidebugmsg = "nothing"
function GUI.debug()
    Debug.track(function() return guidebugmsg end)
end

-- describes an area of the screen containing gui input stuff
GUI.window = {
    rect = Rect.zero(),

    --color palette
    colors = {
        Color(65,141,191)
    },

    --elements
    elements = {},

    --properties
    properties = {
        colorSwapper = {
            capture = function(self, pos)
                if mathx.contains(pos, self.rect) then
                    local on = Color(249,183,148)
                    return Mouse.callbackList{
                        enter = function(state)
                            Debug.log("enter: GUI")
                            self.colors.edge:swap(on)
                        end,
                        exit = function(state)
                            Debug.log("exit: GUI")
                            self.colors.edge:swap()
                        end
                    }
                end
            end
        },
        draggable = {
            capture = function(self, pos)
                if mathx.contains(pos, self.rect) then
                    local lastpos = XY.zero()
                    return Mouse.callbackList{
                        pressed = function(state)
                            if state.pressed.l then
                                lastpos = state.position
                                guidebugmsg = "dragging"
                            end
                        end,
                        held = function(state)
                            if state.pressed.l then
                                local dxy = state.position-lastpos
                                self.rect.x = self.rect.x + dxy.x
                                self.rect.y = self.rect.y + dxy.y
                                lastpos = lastpos + dxy
                            end
                        end
                    }
                end
            end
        },
        resizable = function(edgeSize)
            return {
                capture = function(self, pos)
                    local l,r,b = self.rect:copy(), self.rect:copy(), self.rect:copy()
                    l.w = edgeSize
                    r.x = r.x+r.w-edgeSize
                    r.w = edgeSize
                    b.y = b.y + b.h-edgeSize
                    b.h = edgeSize
                    local lastPos = 0
                    if mathx.contains(pos, l) then
                        return Mouse.callbackList{
                            pressed = function(state)
                                if state.pressed.l then
                                    lastpos = state.position.x
                                    guidebugmsg = "resizing l"
                                end
                            end,
                            held = function(state)
                                if state.pressed.l then
                                    local dx = state.position.x-lastpos
                                    self.rect.x = self.rect.x + dx
                                    self:resize(self.rect.w - dx, self.rect.h)
                                    lastpos = lastpos + dx
                                end
                            end
                        }
                    elseif mathx.contains(pos, r) then
                        return Mouse.callbackList{
                            pressed = function(state)
                                if state.pressed.l then
                                    lastpos = state.position.x
                                    guidebugmsg = "resizing r"
                                end
                            end,
                            held = function(state)
                                if state.pressed.l then
                                    local dx = state.position.x-lastpos
                                    self:resize(self.rect.w + dx, self.rect.h)
                                    lastpos = lastpos + dx
                                end
                            end
                        }
                    elseif mathx.contains(pos, b) then
                        return Mouse.callbackList{
                            pressed = function(state)
                                if state.pressed.l then
                                    lastpos = state.position.y
                                    guidebugmsg = "resizing b"
                                end
                            end,
                            held = function(state)
                                if state.pressed.l then
                                    local dy = state.position.y-lastpos
                                    self:resize(self.rect.w, self.rect.h+dy)
                                    lastpos = lastpos + dy
                                end
                            end
                        }
                    end
                end
            }
        end
    },

    --for mouse capture, use the rect
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

    draw = function(self)
        GUI.colors.background()
        love.graphics.rectangle("fill", self.rect:unpack())
        self.colors.edge()
        love.graphics.rectangle("line", self.rect:unpack())
        GUI.clear()
        GUI.push(self.rect)
        for _,element in pairs(self.elements) do
            element.draw()
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
            e.resize()
        end
    end
}
GUI.window.mt = {
    __call = function(new, rect, elements, properties)
        new.colors = {
            edge = GUI.window.colors[1]
        }
        new.rect = rect
        new.elements = elements or {}
        new.properties = properties or {}

        local list = {}
        table.insert(list, GUI.window.capture)
        for _,p in ipairs(new.properties) do
            if p.capture then
                table.insert(list, p.capture)
            end
        end
        list = Enumerable(list)
        function new:capture(pos)
            local result
            list:Map(function(capture) result = result or capture(self, pos) end)
            return result
        end
        return setmetatable(new, {
            __index = GUI.window
        })
    end
}
setmetatable(GUI.window, GUI.window.mt)

-- An area that can track input and contain elements
GUI.cell = {
    --metatable
    mt = {
        __call = function(new, rect)
            new.rect = rect
            return setmetatable(new, { __index = GUI.cell })
        end
    },

    -- space of cell
    rect = Rect.zero(),

    -- objects contained in cell
    items = {},

    insert = function(self, element)
        table.insert(self.items, element)
    end,

    draw = function(self)
        for _,v in ipairs(self.items)do
            v:draw()
        end
    end
}

-- A set of rules for resizing and moving an element inside a rect
--[[
    each element is a function that takes optional configuration parameters and
    returns a function that takes two rects, fitting one inside the others according
    to the anchor's rules
]]
GUI.anchor = {
    -- these anchors fix the position relative to sides and/or corners
    topleft = function(rect)
        return function(outer)
            return function(box, out)
                box.x = rect.x
                box.y = rect.y
            end
        end
    end,
    topcentre = function(pos)
        return function(box, out)
            box.x = out.w/2 + pos.x
            box.y = pos.y
        end
    end,
    topright = function(pos)
        return function(box, out)
            box.x = out.w + pos.x
            box.y = pos.y
        end
    end,
    midleft = function(pos)
        return function(box, out)
            box.x = pos.x
            box.y = out.h/2 + pos.y
        end
    end,
    midcentre = function(pos)
        return function(box, out)
            box.x = out.w/2 + pos.x
            box.y = out.h/2 + pos.y
        end
    end,
    midright = function(pos)
        return function(box, out)
            box.x = out.w + pos.x
            box.y = out.h/2 +pos.y
        end
    end,
    bottomleft = function(pos)
        return function(box, out)
            box.x = pos.x
            box.y = pos.y + out.h
        end
    end,
    bottomcentre = function(pos)
        return function(box, out)
            box.x = out.w/2 + pos.x
            box.y = pos.y + out.h
        end
    end,
    bottomright = function(pos)
        return function(box, out)
            box.x = out.w + pos.x
            box.y = pos.y + out.h
        end
    end,
    -- these anchors allow setting positions relative to corners by fixed amounts
    custom = function(offset)
        return function(box,out)
            box.x = out.w*offset.x
            box.y = out.h*offset.y
        end
    end
}

-- a base class for gui elements
GUI.element = {
    update = function(self, dt)
        self.anchor(self.rect)
    end,
    rect = Rect.zero(),
    anchor = GUI.anchor.custom(XY.zero())
}
GUI.element.mt = {
    __call = function(new, capture, mouseCallback, draw)
        for k,v in pairs(GUI.element) do
            new[k] = v
        end
        new.capture = capture or new.capture
        new.mouseCallback = mouseCallback
        new.draw = draw
        return setmetatable(new, {
            __index = GUI.defaults
        })
    end,
}
setmetatable(GUI.element, GUI.element.mt)

-- A divider between two sections of an area, creating two new, smaller areas
GUI.partition = {}
GUI.partition.mt = {
    __call = function(new, orientation, position)
        -- capture in rect
        local function capture(self, pos)
            return mathx.contains(pos, self.rect)
        end

        -- set draw based on orientation
        local draw
        if orientation == "horizontal" then
            draw = function(self)
                local r = self.rect
                love.graphic.line(r.x, r.y+r.h/2, r.x+r.w, r.y+r.h/2)
            end
        elseif orientation == "vertical" then
            draw = function(self)
                local r = self.rect
                love.graphic.line(r.x+r.w/2, r.y, r.x+r.w/2, r.y+r.h)
            end
        end
        local new = GUI.element(capture, nil, draw)
        new.orientation = orientation
        new.position = position
        return setmetatable(new, {
            __index = GUI.partition
        })
    end,
    __index = GUI.element
}
setmetatable(GUI.partition, GUI.partition.mt)

--text in a given area
GUI.text = {
}
GUI.text.mt = {
    __call = function(new, text, rect)
        local pos = XY.zero()
        local function draw()
            GUI.push(rect)
            GUI.colors.text()
            pos = GUI.frame:Copy()
            love.graphics.printf(text, GUI.frame.x, GUI.frame.y, rect.w, "left")
        end
        new = GUI.element(nil,nil,draw)
        new.anchor = GUI.anchor.topcentre(rect)
        Debug.track(function() return "text: "..pos end)
        return setmetatable(new, {
            __index = GUI.text
        })
    end,
    __index = GUI.defaults
}
setmetatable(GUI.text, GUI.text.mt)
