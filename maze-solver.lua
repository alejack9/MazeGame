directions = require('directions')

function solve (current, finish, maze)
  current.visited = true
  if current == finish then coroutine.yield(true, 0) end
  local neighbors = maze:getNeighborsWithoutWalls(current)
  if #neighbors == 0 then coroutine.yield(false, 0) end
  if #neighbors == 1 then 
    coroutine.yield( false, 1)
    solve(neighbors[1], finish, maze)
  end
  coroutine.yield(false, #neighbors)
  local coroutines = {}
  for i = 1, #neighbors do 
    table.insert( coroutines, coroutine.create( solve ) ) 
  end
  local cres = false
  local index = 1
  while not cres and #coroutines > 0 do
    _,cres,n = coroutine.resume( coroutines[index], neighbors[index], finish, maze )
    if(not cres and n == 0) then
      table.remove( coroutines, index )
      table.remove( neighbors, index )
    end
    index = ((index) % #coroutines) + 1
    coroutine.yield( cres, #coroutines )
  end
  coroutine.yield( cres, 0)
end

return solve