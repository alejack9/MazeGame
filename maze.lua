local Cell = require('cell')
local directions = require('directions')

Maze = {
  grid = {},
  current = {}
}

function Maze.new(self, rows, cols, obj)
  obj = obj or {}
  obj.rows = rows
  obj.cols = cols
  obj.grid = self.grid
  for i = 1, rows do
    obj.grid[i] = {}
    for j = 1, cols do
        obj.grid[i][j] = Cell:new(i,j)
    end
  end
  obj.grid[rows][cols].open = false
  self.current = self.grid[1][1]
  self.grid[1][1]:toogleCurrent()
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Maze.getCell(self, row, col)
  return self.grid[row][col];
end

function Maze.getNeighborsNotVisited(self, cell)
  toReturn = {}
  for _, step in pairs(directions) do
    if self:isValid(cell.row + step[1], cell.col + step[2]) and not self:getCell(cell.row + step[1],cell.col + step[2]).visited then
      table.insert(toReturn, self:getCell(cell.row + step[1], cell.col + step[2]))
    end
  end
  return toReturn
end

function Maze.getNeighborsWithoutWalls(self, cell)
  local toReturn = {}
  for direction, step in pairs(directions) do
    if self:isValid(cell.row + step[1], cell.col + step[2]) then
      local target = self:getCell(cell.row + step[1], cell.col + step[2])
      if not target.visited and not cell.walls[direction] then
        table.insert(toReturn, target)
      end
    end
  end
  return toReturn  
end

function Maze.resetVisited(self)
  for row = 1, self.rows do
    for cell = 1, self.cols do
      self.grid[row][cell].visited = false
    end
  end
end

function Maze.removeWall(self, cell1, cell2)
  if cell1.row - cell2.row == 0 then
    if cell1.col - cell2.col == 1 then
      cell1.walls.left = false
      cell2.walls.right = false
    else
      cell1.walls.right = false
      cell2.walls.left = false
    end
  else
    if cell1.row - cell2.row == 1 then
      cell1.walls.up = false
      cell2.walls.down = false
    else
      cell1.walls.down = false
      cell2.walls.up = false
    end
  end
end

function Maze.draw(self, width, height)
  for i = 1, self.rows do
    for j = 1, self.cols do
      self.grid[i][j]:draw(width, height)
    end
  end
end

function Maze.isValid(self, row, col)
  return row >= 1 and col >= 1 and row <= self.rows and col <= self.cols;
end

function Maze.pierce(self, percentage)
  local walls = {"down", "up", "right", "left"}
  for i=1, math.ceil(percentage * self.rows * self.cols) do
      local row, col = math.random(2, self.rows - 1), math.random(2, self.cols - 1)
      local wall = walls[math.random(1, 4)]
      self:removeWall(self:getCell(row, col), self:getCell(row + directions[wall][1], col + directions[wall][2]))
  end
end

function Maze.move(self, direction)
  if self:isValid(self.current.row + directions[direction][1], self.current.col + directions[direction][2]) and not self.current.walls[direction] then
    local next = self:getCell(self.current.row + directions[direction][1],self.current.col + directions[direction][2])
    Cell.toogleCurrent(next)
    Cell.toogleCurrent(self:getCell(self.current.row, self.current.col))
    self.current = next
    if next.hasKey then next.hasKey = false; self:getCell(self.rows, self.cols).open = true end
    return true
  end
  return false
end


table.filter = function(t, filterIter)
  local out = {}
  for k, v in pairs(t) do
    if filterIter(v, k, t) then table.insert(out,v) end
  end
  return out
end

table.map = function(t, mapFun)
  local out = {}
  for k, v in pairs(t) do
    table.insert(out, mapFun(v))
  end
end

return Maze