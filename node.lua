local directions = require('directions')
Node = {}
Node.__index = Node

function Node.new(_cell)
  return setmetatable(
    {
      cell = _cell,
      steps = 0,
      children = {},
      inserted = true
    }, Node)
--  local obj = {}
--  obj.cell = self.cell
--  obj.steps = steps
--  setmetatable(obj, self)
--  self.__index = self
--  return obj
end

function Node.addChildren(self, _children)
  for _, child in ipairs(_children) do
    local node = Node.new(child)
    table.insert(self.children, node)
--    child.visited = true
  end
end

function Node.print(self, tab)
  tabs = tabs or 0
  print('I\'m', self.cell:tostring())
  io.write('Children: ')
--  for i = 0,tabs do io.write(' ') end
  for _, node in ipairs(self.children) do
    io.write(node.cell:tostring())
    io.write(' ') 
  end
  print()
  for _, node in ipairs(self.children) do
    node:print()
--    node:print(tab + 1)
  end
end

--function Maze.getNeighbors(self, cell)
--  local toReturn = {}
--  for direction, step in pairs(directions) do
--    if maze:isValid(cell.row + step[1], cell.col + step[2]) then
--      if not cell.walls[direction] then
--        table.insert(toReturn, maze:getCell(cell.row + step[1], cell.col + step[2]))
--      end
--    end
--  end
--  return toReturn  
--end

function Node.build(self, maze)
  self:addChildren(maze:getNeighborsWithoutWalls(self.cell))
  for _, child in ipairs(self.children) do
    child:build(maze)
  end
end
--function Node.build(self, maze)
--  local neighbors = maze:getNeighborsWithoutWalls(self.cell)
--  self:addChildren(neighbors)
  
--end

return Node