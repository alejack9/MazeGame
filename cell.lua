require('colors')
Cell = {
  walls = {
    up = true,
    right = true,
    down = true,
    left = true
  },
  visited = false
}

function Cell.tostring(self)
  return self.row .. 'x' .. self.col
end

function Cell.toogleCurrent(self)
  self.current = not self.current
end

function Cell.new(self, row, col)
  local obj = {}
  obj.row = row
  obj.col = col
  obj.visited = self.visited
  obj.walls = {}
  obj.walls.up = self.walls.up
  obj.walls.right = self.walls.right
  obj.walls.down = self.walls.down
  obj.walls.left = self.walls.left
  obj.status = {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Cell.draw(self, width, height)
  local x = (self.col - 1) * width
  local y = (self.row - 1) * height
  if self.status then
    for color, state in pairs(self.status) do
      love.graphics.printf(color, MAZE_WIDTH, 60, INFO_WIDTH - 10, "left", 0, 1, 1, -10)
      if state then
        love.graphics.setColor(unpack(colors[color]))
        love.graphics.rectangle("fill", x, y, width, height)
      end
    end
  end
  if self.isLast then
    if
    self.open then  love.graphics.setColor(unpack(colors.OPENEDLAST))
    else            love.graphics.setColor(unpack(colors.CLOSEDLAST))
    end
    love.graphics.rectangle("fill", x, y, width, height)
  end
  if self.hasKey then
    local key = love.graphics.newImage('key.png')
    local quad = love.graphics.newQuad(0, 0, key:getWidth(), key:getHeight(), width,height)
    love.graphics.setColor(unpack(colors.KEYCELL))
    love.graphics.ellipse("fill", x + width / 2, y + height / 2, width / 2, height / 2)
    love.graphics.setColor(1, 1, 1, 100)
    love.graphics.draw(key, quad, x, y)
  end

  if self.current then
    love.graphics.setColor(unpack(colors.CURRENT))
    love.graphics.ellipse("fill",x+width/2,y+height/2,width/2,height/2)
  end
  love.graphics.setColor(unpack(colors.WALLS))
  if self.walls.up then love.graphics.line(x, y, x + width, y) end
  if self.walls.right then love.graphics.line(x + width, y, x + width, y + height) end
  if self.walls.down then love.graphics.line(x, y + height, x + width, y + height) end
  if self.walls.left then love.graphics.line(x, y, x, y + height) end
end

return Cell