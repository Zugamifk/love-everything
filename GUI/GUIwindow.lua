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
                    local lastpos = XY.zero
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
            element:draw()
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
GUI.window.mt = {
    __call = function(new, rect, elements, properties)
        new.colors = {
            edge = GUI.window.colors[1]
        }
        new.rect = rect
        new.elements = elements or {}
        for _,v in pairs(elements) do
            v.anchor = v.anchor(rect)
            v.anchor(v.rect, rect)
            Debug.log(v.rect.."")
        end

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
