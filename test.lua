local Maze = require('maze')
solver = require('maze-solver')

function recursiveBacktrack(maze, current, visited)
  visited = visited and visited + 1 or 0 
  current.visited = true
  if visited == maze.rows * maze.cols then
    return true
  end
  repeat
    local neighbors = maze:getNeighbors(current)
    if #neighbors == 0 then
      return false
    end
    local next = neighbors[math.random(1, #neighbors)]
    maze:removeWall(current, next)
  until recursiveBacktrack(maze, next, visited)
end


ROWS = 10
COLS = 10
PIERCE_PERCENTAGE = 0.5

maze = Maze:new(ROWS, COLS)

recursiveBacktrack(maze, maze:getCell(1, 1))
--recursiveBacktrackWithStack(maze, maze:getCell(1, 1))
maze.grid[1][1].walls.up = false
maze.grid[ROWS][COLS].walls.down = false
maze.grid[math.random(1,ROWS)][math.random(1,COLS)].hasKey = true
maze:pierce(PIERCE_PERCENTAGE)

resolve = false
for _, rrow in ipairs(maze.grid) do for _,cell in ipairs(rrow) do cell.visited = false end end
c = coroutine.create(solver)
coroutine.resume(c, maze:getCell(1,1), maze:getCell(ROWS,COLS), maze, nil)
res = false

while not res do
  _,res = coroutine.resume(c)
end
