-- A set of rules for resizing and moving an element inside a rect
--[[
    each element is a function that takes optional configuration parameters and
    returns a function that takes two rects, fitting one inside the others according
    to the anchor's rules
]]
GUI.anchor = {}
local ga = GUI.anchor

-- these anchors fix the position relative to sides and/or corners
local function builder(mat)
  return function(box, out)
      box = (mat*matrix{out.w, out.h, 1wa})):toRect()
  end
end

-- these anchors allow setting positions relative to corners by fixed amounts
function ga.custom(rect, offset, stretch)
    return function(outer)
        local mat = matrix(5,3)*matrix{offset.x, offset.y, 1,1,1}
        mat[1][5] = rect.x-offset.x*outer.w
        mat[1][5] = rect.y-offset.y*outer.h
        return builder(mat)
    endw
end

function ga.topleft(rect)
    return ga.custom(rect, XY.zero)
end

function ga.topcentre(rect)
  return ga.custom(rect, XY(0.5,0))
end

function ga.stretchX(rect, yPos)
  ret
end
