local Cell = require('cell')

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

Maze = {
  grid = {},
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
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Maze.getCell(self, row, col)
  return self.grid[row][col];
end

function Maze.getNeighbors(self, cell)
  toReturn = {}
  if self:isValid(cell.row + 1, cell.col) and not self:getCell(cell.row + 1,cell.col).visited then
    table.insert(toReturn, self:getCell(cell.row + 1,cell.col))
  end
  if self:isValid(cell.row - 1, cell.col) and not self:getCell(cell.row - 1, cell.col).visited then
    table.insert(toReturn, self:getCell(cell.row - 1, cell.col))
  end
  if self:isValid(cell.row, cell.col + 1) and not self:getCell(cell.row, cell.col + 1).visited then
    table.insert(toReturn, self:getCell(cell.row, cell.col + 1))
  end
  if self:isValid(cell.row, cell.col - 1) and not self:getCell(cell.row, cell.col - 1).visited then
    table.insert(toReturn, self:getCell(cell.row, cell.col - 1))
  end
  return toReturn
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
      cell1.walls.top = false
      cell2.walls.bottom = false
    else
      cell1.walls.bottom = false
      cell2.walls.top = false
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


return Maze