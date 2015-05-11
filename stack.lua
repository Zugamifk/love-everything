Stack = {}
Stack_mt = {
    __index = Stack
}
setmetatable(Stack, {
    __call = function(...) return Stack.new(...) end
})

function Stack:new()
    local s = {}
    s.items = {}
    return setmetatable(s, Stack_mt)
end

function Stack:Push(item)
    self.items[#self.items+1] = item
end

function Stack:Pop()
    local item = self.items[#self.items]
    self.items[#self.items] = nil
    return item
end

function Stack:Clear()
    self.items = {}
end
