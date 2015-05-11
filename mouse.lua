Mouse = {

    -- Last recorded state of mouse
    state = {
        position = XY.zero(), --last recorded position
        pressed = {}, -- currently held buttons
    },

    -- Last recorded mouse target
    target = "None",
    mouseEvent = function() end,

    -- valid events to pass to event handlers
    events = {
        enter = "enter",
        hover = "hover",
        exit = "exit",
        pressed = "pressed",
        held = "held",
        released = "released"
    },

    -- A sequence of callback that get called in order ntil one returns true
    layers = {},
    layerSequence = {}
}

function Mouse.callbackList(callbacks)
    return function(state, event)
        local e = callbacks[event]
        if e then
            e(state)
        end
    end
end

function Mouse.init()
    Debug.track(function() return Mouse.target end)
end

function Mouse.update()
    Mouse.mouseEvent(Mouse.state, Mouse.events.held)
end

function Mouse.getTarget()
    for index,layer in ipairs(Mouse.layerSequence) do
        local result = Mouse.layers[layer](Mouse.state.position)
        if result then
            return layer, result
        end
    end
    return "none", function() end
end

function Mouse.addLayer(name, callback, index)
    index = index or #Mouse.layerSequence+1
    Mouse.layers[name] = callback
    Mouse.layerSequence[index] = name
end

function Mouse.pressed(x,y,button)
    Mouse.state.pressed[button] = true
    Mouse.mouseEvent(Mouse.state, Mouse.events.pressed)
end

function Mouse.released(x,y,button)
    Mouse.state.pressed[button] = false
    Mouse.mouseEvent(Mouse.state, Mouse.events.released)
end

function Mouse.moved(x,y)
    Mouse.state.position = XY(x,y)

    if Mouse.state.pressed.l then
         return -- ignore while dragging
    end

    local result, events = Mouse.getTarget()
    Mouse.mouseEvent = events
    if result ~= Mouse.target then
        Mouse.mouseEvent(Mouse.state, Mouse.events.exit)
        Mouse.target = result
        if result then
            events(Mouse.state, Mouse.events.enter)
        end
    else
        events(Mouse.state, Mouse.events.hover)
    end

end
