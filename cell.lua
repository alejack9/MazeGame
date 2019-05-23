Cell = {
  walls = {
    top = true,
    right = true,
    bottom = true,
    left = true
  },
  visited = false
}

function Cell.tostring(self)
      return self.row .. 'x' .. self.col
end


function Cell.new(self, row, col, obj)
    obj = obj or {}
    obj.row = row
    obj.col = col
    obj.visited = self.visited
    obj.walls = {}
    obj.walls.top = self.walls.top
    obj.walls.right = self.walls.right
    obj.walls.bottom = self.walls.bottom
    obj.walls.left = self.walls.left
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Cell.draw(self, width, height)
    local x = (self.col - 1) * width
    local y = (self.row - 1) * height
    love.graphics.setColor(15,0,10,1)
    if self.visited then love.graphics.rectangle("fill", x,y,width,height) end
    love.graphics.setColor(255,255,255,1)
    if self.walls.top then love.graphics.line(x, y, x + width, y) end
    if self.walls.right then love.graphics.line(x + width, y, x + width, y + height) end
    if self.walls.bottom then love.graphics.line(x, y + height, x + width, y + height) end
    if self.walls.left then love.graphics.line(x, y, x, y + height) end
end

return Cell