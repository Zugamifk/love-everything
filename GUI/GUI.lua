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
    frame = XY.zero,
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
        GUI.frame = XY.zero
    end
}

local guidebugmsg = "nothing"
function GUI.debug()
    Debug.track(function() return guidebugmsg end)
end

require('GUI/GUIwindow')
require('GUI/GUIanchor')
require('GUI/GUIelement')
require('GUI/GUIcell')
require('GUI/GUIpartition')
require('GUI/GUItext')
