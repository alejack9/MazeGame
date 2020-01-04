local Cell = require('cell')
local directions = unpack(require('directions'))

Maze = {
  grid = {},
  current = {}
}

function Maze.recursiveBacktrack(maze, current, visited)
  visited = visited and visited + 1 or 0 
  current.visited = true
  if visited == maze.rows * maze.cols then
    return true
  end
  repeat
    local neighbors = maze:getNeighbors(current, function(next) return not next.visited end)
    if #neighbors == 0 then
      return false
    end
    local next = neighbors[math.random(1, #neighbors)]
    maze:removeWall(current, next)
  until Maze.recursiveBacktrack(maze, next, visited)
end

function Maze.new(self, _rows, _cols, startRow, startCol, lastRow, lastCol)
  lastRow   , lastCol   = lastRow   or _rows  , lastCol   or _cols
  startRow  , startCol  = startRow  or    1   , startCol  or    1
  local obj = {
    rows = _rows,
    cols = _cols,
    grid = {}
  }
  for i = 1, _rows do
    obj.grid[i] = {}
    for j = 1, _cols do
      obj.grid[i][j] = Cell:new(i,j)
    end
  end

  obj.start = obj.grid[startRow][startCol]
  obj.current = obj.start
  obj.grid[startRow][startCol]:toogleCurrent()

  obj.grid[lastRow][lastCol].open = false
  obj.grid[lastRow][lastCol].isLast = true
  obj.last = obj.grid[lastRow][lastCol]
  setmetatable(obj, self)
  self.__index = self
  Maze.recursiveBacktrack(obj, obj.grid[1][1])
  return obj
end



function Maze.getCell(self, row, col)
  return self.grid[row][col];
end

function Maze.setKey(self, row, col)
  maze.keyPos = maze:getCell(row, col)
  maze.keyPos.hasKey = true
end

-- predicate: (next, current, direction) -> boolean
function Maze.getNeighbors(self, cell, predicate)
  local toReturn = {}
  for direction, step in pairs(directions) do
    if self:isValid(cell.row + step[1], cell.col + step[2]) then
      local next = self:getCell(cell.row + step[1], cell.col + step[2])
      if predicate(next, cell, direction) then
        table.insert(toReturn, next)
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
  for i = 1, math.ceil(percentage * self.rows * self.cols) do
    local row, col, wall
    repeat
      row, col = math.random(2, self.rows - 1), math.random(2, self.cols - 1)
      wall = walls[math.random(1, #walls)]
    until not self:isValid(row, col) or self:isValid(row + directions[wall][1], col + directions[wall][2])
    self:removeWall(self:getCell(row, col), self:getCell(row + directions[wall][1], col + directions[wall][2]))
  end
end

function Maze.move(self, direction)
  if self:isValid(self.current.row + directions[direction][1], self.current.col + directions[direction][2]) and not self.current.walls[direction] then
    local next = self:getCell(self.current.row + directions[direction][1],self.current.col + directions[direction][2])
    Cell.toogleCurrent(next)
    Cell.toogleCurrent(self:getCell(self.current.row, self.current.col))
    self.current = next
    local key = next.hasKey
    if key then
      next.hasKey = false
      self.last.open = true
    end
    return {true, key}
  end
  return {false}
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