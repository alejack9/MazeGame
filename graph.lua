directions = require("directions")

Graph = {
  nodes = {}
}

function Graph.new(self)
  local obj = {
    nodes = {}
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Graph.tostring(self) 
  local toReturn = ""
  for _,node in pairs(self.nodes) do
    toReturn = toReturn..node.cell:tostring() .. "\n"
    toReturn = toReturn.."Children : "
    for _,child in pairs(node.children) do
      toReturn = toReturn..child:tostring() .. " "
    end
    toReturn = toReturn .. "\n\n"
  end
  return toReturn
end



function shallowcopy(orig)
  local copy = {}
  for orig_key, orig_value in pairs(orig) do
    copy[orig_key] = orig_value
  end
  return copy
end

function Graph._DFS(self, maze, current)
  local _children = maze:getNeighborsWithoutWalls(current)
  local toWork = shallowcopy(_children)

  if #_children == 1 and _children[1].visited and not current.hasKey and not current.isLast then
    return true
  end

  table.insert( self.nodes, {cell = current, children = _children })
  current.visited = true

  local i = 1
  for _,v in ipairs(toWork) do
--    if not v.visited then self:_DFS(maze, v) end
    if not v.visited then
      local toRemove = self:_DFS(maze, v)
      if toRemove then
        table.remove(_children, i)
        i = i - 1
      end
    end
    i = i + 1
  end

  if #_children == 1 and _children[1].visited  and not current.hasKey and not current.isLast then
    return true
  end
end

function Graph.DFS(self, maze, start)
  for row = 1, maze.rows do
    for cell = 1, maze.cols do
      maze:getCell(row,cell).visited = false
    end
  end
  self:_DFS(maze, start)
end

--function Graph.scanAllNodes(self, maze, current)
--    steps = steps + 1
--    table.insert(self.nodes, { cell = current, children = maze:getNeighborsWithoutWalls(current) })
--    if current.row == maze.rows and current.col == maze.cols then return end
--    if maze:isValid(current.row + directions["right"][1], current.col + directions["right"][2]) then
--        next = maze:getCell(current.row + directions["right"][1], current.col + directions["right"][2])
--    elseif maze:isValid(current.row + directions["down"][1], 1) then
--        next = maze:getCell(current.row + directions["down"][1], 1)
--    end
--    self:build(maze, next)
--end

function Graph.build(self, maze, current )
--  self:scanAllNodes(maze, current)
  self:DFS(maze, maze.start)
end

return Graph