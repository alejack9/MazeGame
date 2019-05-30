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
  for _,node in pairs(self.nodes) do
    local x = (node.cell.col - 1) * width
    local y = (node.cell.row - 1) * height
    love.graphics.setColor(1,0,0,100)
    love.graphics.ellipse("fill", x + width / 2, y + height / 2, width / 2 - 0.30 * width, height / 2 - 0.3 * height)
    for _, neighbor in pairs(node.children) do 
      local x2 = (neighbor.col - 1) * width
      local y2 = (neighbor.row - 1) * height
      love.graphics.line(x + width / 2, y + height / 2, x2 + width / 2, y2 + height / 2)
    end
  end
  for _, node in pairs(self.nodes) do
    local x = (node.cell.col - 1) * width
    local y = (node.cell.row - 1) * height
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf(node.hE ..'\n'.. node.hK,love.graphics.newFont("VeraBd.ttf",16) , x, y + height / 2, width, "center")
  end
end

function Graph.tostring(self) 
  local toReturn = ""
  for _,node in pairs(self.nodes) do
    toReturn = toReturn .. node.cell:tostring() .. ' , ' .. node.h .. "\n"
    toReturn = toReturn .. "Children : "
    for _,child in pairs(node.children) do
      toReturn = toReturn .. child:tostring() .. " "
    end
    toReturn = toReturn .. "\n\n"
  end
  return toReturn
end

function Graph.positionToIndex(self, mazeCols, cell)
  return mazeCols * (cell.row - 1) + cell.col
end

function shallowcopy(orig)
  local copy = {}
  for orig_key, orig_value in pairs(orig) do
    copy[orig_key] = orig_value
  end
  return copy
end

function Graph._DFS(self, maze, current, heuristicExit, heuristicKey)
  local _children = maze:getNeighbors(current, function(next, current, direction) return not current.walls[direction] end)
  local toWork = shallowcopy(_children)

  if #_children == 1 and _children[1].visited and not current.hasKey and not current.isLast then
    return true
  end

  local POSITION = self:positionToIndex(maze.cols, current)

  self.nodes[POSITION] = {cell = current, children = _children, hE = heuristicExit(current, maze.last), hK = heuristicKey(current, maze.keyPos) }
  current.visited = true

  local i = 1
  for _,v in ipairs(toWork) do
    if not v.visited then
      local toRemove = self:_DFS(maze, v, heuristicExit, heuristicKey)
      if toRemove then
        local POS2 =  self:positionToIndex(maze.cols, v)
        table.remove(_children, i)
        self.nodes[POS2] = nil
        i = i - 1
      end
    end
    i = i + 1
  end

  if #_children == 1 and _children[1].visited  and not current.hasKey and not current.isLast then
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

function Graph.build(self, maze, current, heuristicExit, heuristicKey)
  heuristicExit, heuristicKey = heuristic or manhattan , heuristic or manhattan 
  self:DFS(maze, maze.start, heuristicExit, heuristicKey)
end

return Graph