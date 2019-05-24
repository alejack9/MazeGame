math.randomseed(os.time())
local Maze = require('maze')
solver = require('maze-solver')
--local Stack = require('stack')

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
--    FULLSCREEN=true
--    WINDOW_WIDTH = 1920
--    WINDOW_HEIGHT = 1080
--    ROWS = 100
--    COLS = math.ceil(ROWS * 1.75)

    WINDOW_WIDTH = 800
    WINDOW_HEIGHT = 800
    ROWS = 10
    COLS = 10
    PIERCE_PERCENTAGE = 0.5
    width = WINDOW_WIDTH / COLS
    height = WINDOW_HEIGHT / ROWS
    
    start()
    
    drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, false)
end


function love.update(dt)
    love.timer.sleep(1/30 - dt)
end

function start()
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
    coroutine.resume(c, maze:getCell(1,1), maze:getCell(ROWS,COLS), maze)
    res = false

end

events = {
  ["return"] = function() resolve = not resolve end,
  ["escape"] = function() love.event.push('quit') end,
  ["r"] = start,
  __index = function(t, k)
    k = (k == 'a' and 'left' or (k == 'd' and 'right' or (k == 's' and 'down' or (k == 'w' and 'up' or k))))
    if k ~= 'left' and k ~= 'right' and k ~= 'down' and k ~= 'up' then return function() end end
    return function() maze:move(k) end
  end
}
setmetatable(events, events)

function love.keypressed(k)
  events[k]()
end

function drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
    love.window.setFullscreen(FULLSCREEN and true or false)
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
end


function love.draw()
    maze:draw(width, height)
    if resolve and not res then
        _,res = coroutine.resume(c)
    end
end

-- complexity (nm)
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

-- old (2nm)
--function recursiveBacktrackWithStack(maze, current, stack)
--    stack = stack or Stack:new(current)
--    current.visited = true
--    if stack:length() == 0 then
--        return
--    end
--    local neighbors = maze:getNeighbors(current)
--    if #neighbors == 0 then
--        return recursiveBacktrackWithStack(maze, stack:pop(), stack)
--    end
--    local next = neighbors[math.random(1, #neighbors)]
--    stack:push(next)
--    maze:removeWall(current, next)
--    recursiveBacktrackWithStack(maze, next, stack)
--end