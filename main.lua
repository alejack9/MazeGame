math.randomseed(os.time())
local Maze = require('maze')
local Stack = require('stack')

function love.load()
  local windowSize = {600, 600};
  love.window.setMode(windowSize[1],windowSize[2])
  maze = Maze:new(104,104)
  width = windowSize[1] / maze.cols
  height = windowSize[2] / maze.rows
  recursiveBacktrack(maze, maze:getCell(1, 1));
end

function recursiveBacktrack(maze, current, stack)
  stack = stack or Stack:new(current)
  current.visited = true;
  if stack:length() == 0 then return end
  local neighbors = maze:getNeighbors(current);
  if #neighbors == 0 then
    return recursiveBacktrack(maze, stack:pop(), stack);
  end
  local next = neighbors[math.random(1, #neighbors)]
  stack:push(next)
  maze:removeWall(current, next)
  recursiveBacktrack(maze, next, stack)
end

function love.draw()
  maze:draw(width, height)
end