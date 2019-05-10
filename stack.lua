Stack = {
  _et = {},
  new = function(self, v, obj)
    obj = obj or {}
    obj._et = self._et
    if v then table.insert(obj._et, v) end
    setmetatable(obj, self)
    self.__index = self
    return obj
  end,
  push = function(self, ...)
    if ... then
      local targs = {...}
      -- add values
      for _,v in ipairs(targs) do
        table.insert(self._et, v)
      end
    end
  end,
  pop = function(self, num)
    local num = num or 1
    local entries = {}
    -- get values into entries
    for i = 1, num do
      if #self._et ~= 0 then
        table.insert(entries, self._et[#self._et])
        table.remove(self._et)
      else
        break
      end
    end
    return unpack(entries)
  end,
  length = function(self)
      return #self._et
  end,
  draw = function(self, drawFun)
    drawFun = drawFun or print
    for i,v in pairs(self._et) do
      drawFun(i, v)
    end
  end
}

return Stack