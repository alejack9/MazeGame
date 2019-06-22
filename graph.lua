local directions = unpack(require('directions'))

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

function Graph.draw(self, width, height)
  for _,row in pairs(self.nodes) do
    for _, node in pairs(row) do
      if node then
        local x = (node.cell.col - 1) * width
        local y = (node.cell.row - 1) * height
        love.graphics.setColor(9/255,76/255,232/255,100)
        for _, neighbor in ipairs(node.children) do
          local x2 = (neighbor.cell.col - 1) * width
          local y2 = (neighbor.cell.row - 1) * height
          love.graphics.line(x + width / 2, y + height / 2, x2 + width / 2, y2 + height / 2)
        end
        if node.cell.current then love.graphics.setColor(unpack(colors.CURRENT))
        elseif node.cell.hasKey then love.graphics.setColor(unpack(colors.KEYCELL))
        elseif node.cell.isLast then love.graphics.setColor(unpack(colors.OPENEDLAST))
        end
        love.graphics.ellipse("fill", x + width / 2, y + height / 2, width / 2 - 0.30 * width, height / 2 - 0.3 * height)
      end
    end
  end
--  for _,row in pairs(self.nodes) do
--    for _, node in pairs(row) do
--      if node then
--        local x = (node.cell.col - 1) * width
--        local y = (node.cell.row - 1) * height
--        love.graphics.setColor(1,1,1,1)
--        love.graphics.printf(node.attrToExit.h ..'|'.. node.attrToKey.h, x, y + height / 2, width, "center")
--      end
--    end
--  end
end


function shallowcopy(orig)
  local copy = {}
  for orig_key, orig_value in pairs(orig) do
    copy[orig_key] = orig_value
  end
  return copy
end


function Graph.getNode(self, _cell, maze, heuristicExit, heuristicKey)
  if not self.nodes[_cell.row] then 
    self.nodes[_cell.row] = {}
  else 
    if self.nodes[_cell.row][_cell.col] then 
      return self.nodes[_cell.row][_cell.col]
    end
  end
  self.nodes[_cell.row][_cell.col] = {
    cell = _cell, 
    children = {},
    attrToKey = {h = heuristicKey(_cell, maze.keyPos)},
    attrToExit = {h = heuristicExit(_cell, maze.last)}
  }
  return self.nodes[_cell.row][_cell.col]
end

function Graph._DFS(self, maze, current, heuristicExit, heuristicKey)
  local _children = maze:getNeighbors(current, function(next, current, direction) return not current.walls[direction] end)
  local toWork = shallowcopy(_children)

  if #_children == 1 and _children[1].visited and not current.hasKey and not current.isLast then
    return true
  end
  local node = self:getNode(current, maze, heuristicExit, heuristicKey)

  current.visited = true

  local i = 1
  for _,v in ipairs(toWork) do
    if not v.visited then
      local toRemove = self:_DFS(maze, v, heuristicExit, heuristicKey)
      if toRemove then
        table.remove(_children, i)
        if self.nodes[v.row] and self.nodes[v.row][v.col] then self.nodes[v.row][v.col] = nil end
        i = i - 1
      end
    end
    i = i + 1
  end
  for _, child in pairs(_children) do
    table.insert( node.children, self:getNode(child, maze, heuristicExit, heuristicKey) )
  end

  if #_children == 1 and _children[1].visited and not current.hasKey and not current.isLast then
    return true
  end
end

function Graph.DFS(self, maze, start, heuristicExit, heuristicKey)
  maze:resetVisited()
  self:_DFS(maze, start, heuristicExit, heuristicKey)
end

manhattan = function(start, target)
  return math.abs(target.row - start.row) + math.abs(target.col - start.col) 
end

function Graph.build(self, maze, start, heuristicExit, heuristicKey)
  heuristicExit, heuristicKey = heuristicExit or manhattan , heuristicKey or manhattan 
  self:DFS(maze, maze.start, heuristicExit, heuristicKey)
end

return Graph