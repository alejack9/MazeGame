Solver = {
    
equals = function (pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y 
end,


isValid = function (position, maze)
    return position ~= nil and 
        maze:isValid(position.y,position.x) and not
        maze:getCell(position.y,position.x).visited
end,
    

getNeighbors = function (position, maze)
    local _neighbors = {}
    local walls = maze:getCell(position.y, position.x).walls
    if Solver.isValid({y = position.y - 1, x = position.x}, maze) and not walls.top 
    then
        table.insert( _neighbors, {y = position.y - 1, x = position.x})
    end
    if Solver.isValid({y = position.y + 1, x = position.x}, maze) and not walls.bottom
    then
        table.insert( _neighbors, {y = position.y + 1, x = position.x})
    end
    if Solver.isValid({y = position.y, x = position.x - 1}, maze) and not walls.left
    then
        table.insert( _neighbors, {y = position.y, x = position.x - 1})
    end
    if Solver.isValid({y = position.y, x = position.x + 1}, maze) and not walls.right
    then
        table.insert( _neighbors, {y = position.y, x = position.x + 1})
    end
    return _neighbors
end,
    

setVisited = function (position, maze) 
    maze:getCell(position.y,position.x).visited = true
end,
    
    
doStep = function ( current, finish, maze )
    Solver.setVisited(current,maze)
    if Solver.equals(current, finish) then coroutine.yield( true, {} ) end

    neighbors = Solver.getNeighbors(current, maze)
    if #neighbors == 0 then 
    local next = coroutine.yield( false, {} )
    Solver.doStep(next, finish, maze)
    end

    local next = coroutine.yield(false, neighbors)
    Solver.doStep(next, finish, maze)
end,
    
    
solve_maze = function(start, exit, maze)
    
    local step_stack = {start}
    local c = coroutine.create( Solver["doStep"] )
    
    local i = 1
    local isFinish = false
    
    while not isFinish do
      current = table.remove( step_stack, i)
      _,isFinish,neighbors = coroutine.resume( c, current, exit, maze)
      for _,n in pairs(neighbors) do
        table.insert( step_stack, i, n )
      end
      if #step_stack > 0 then
        i = (i % #step_stack) + 1
      end
    end
    
    return isFinish
end,
    
    
solve_maze_rec = function (start, exit, maze)
    
    local c = coroutine.create( Solver["doStep"]  )
    
    local _solve
    _solve = function (index, step_stack)
    
      if #step_stack == 0 then 
        return false 
      end
    
      current = table.remove( step_stack, index)
      _,isFinish,neighbors = coroutine.resume( c, current, exit, maze)
    
      if isFinish then 
        return true 
      else
        for _,n in pairs(neighbors) do
          table.insert( step_stack, index, n )
        end
    
        if #step_stack > 0 then
          index = (index % #step_stack) + 1
          return _solve(index, step_stack)
        else 
          return false 
        end
      end
    end
    
    return _solve(1, {start})
    
end

}

return Solver