math.randomseed(os.time())
local Maze = require('maze')
solver = require('maze-solver')
local Stack = require('stack')
Graph = require('graph')

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").on(); require("mobdebug").coro(); require("mobdebug").start() end
--    FULLSCREEN=true
--    MAZE_WIDTH = 1920 - 300
--    INFO_WIDTH = 300
--    WINDOW_HEIGHT = 1080
--    ROWS = 10

  FULLSCREEN=false
  MAZE_WIDTH    = 600
  WINDOW_HEIGHT = 600
  INFO_WIDTH = 200
  ROWS = 5
----  COLS = 10
  COLS = math.ceil(ROWS * (MAZE_WIDTH / WINDOW_HEIGHT))
  PIERCE_PERCENTAGE = 0
  
  width = MAZE_WIDTH / COLS
  height = WINDOW_HEIGHT / ROWS

  start()

  drawWindow(MAZE_WIDTH + INFO_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
end


function love.update(dt)
  love.timer.sleep(1/30 - dt)
end

function start()
  maze = Maze:new(ROWS, COLS)

  recursiveBacktrack(maze, maze:getCell(1, 1))

  maze:getCell(1,1).walls.up = false
  maze:getCell(ROWS,COLS).walls.down = false
  
  local keyPos
  repeat
    keyPos = { math.random(1,ROWS),math.random(1,COLS) }
  until keyPos[1] ~= 1 and keyPos[2] ~= 1 
  maze:getCell(unpack(keyPos)).hasKey = true

  maze:pierce(PIERCE_PERCENTAGE)

  graph = Graph:new()
  graph:build(maze, maze:getCell(1, 1))
  print(graph:tostring())

  resolve = false
  for _, rrow in ipairs(maze.grid) do for _,cell in ipairs(rrow) do cell.visited = false end end
  c = coroutine.create(solver)
  coroutine.resume(c, maze:getCell(1,1), maze:getCell(ROWS,COLS), maze)
  res = false
  steps = 0
end

prevs = Stack:new()

keys = {
  ["return"] = function() resolve = not resolve end,
  ["escape"] = function() love.event.push('quit') end,
  ["r"] = start,
  opposite = function(k)
    if k == "left" then return "right" elseif k == "right" then return "left" elseif k == "up" then return "down" elseif k == "down" then return "up" end
  end,
  __index = function(t, k)
    k = (k == 'a' and 'left' or (k == 'd' and 'right' or (k == 's' and 'down' or (k == 'w' and 'up' or k))))
    if k ~= 'left' and k ~= 'right' and k ~= 'down' and k ~= 'up' then return function() end end
    return function()
      if maze:move(k) then
        if k == keys.opposite(prevs:top()) then
          prevs:pop()
          steps = steps - 1;
        else
          prevs:push(k)
          steps = steps + 1
          -- to continue
        end
      end
    end
  end
}
setmetatable(keys, keys)

function love.keypressed(k)
  keys[k]()
end

function drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
  FULLSCREEN = FULLSCREEN and true or false
  if FULLSCREEN then love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true, fullscreentype = "desktop"})
  else love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT) end
end


function love.draw()
    love.graphics.printf("steps: " .. steps, MAZE_WIDTH, 10, INFO_WIDTH - 10, "left", 0, 1, 1, -10)
--  love.graphics.printf(graph:tostring(), MAZE_WIDTH, 10, INFO_WIDTH - 10, "left", 0, 1, 1, -10)
  maze:draw(width, height)
  if resolve and not res then
    _,res = coroutine.resume(c)
  end
  if maze.current == maze:getCell(ROWS,COLS) and maze:getCell(ROWS,COLS).open then
    love.graphics.setColor(10/255, 10/255, 10/255, 1)
    love.graphics.rectangle("fill",0,0,MAZE_WIDTH,WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("YOU WIN!",0, WINDOW_HEIGHT / 2, MAZE_WIDTH / 2.5, "center", 0, 2.5, 5)
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
    local neighbors = maze:getNeighborsNotVisited(current)
    if #neighbors == 0 then
      return false
    end
    local next = neighbors[math.random(1, #neighbors)]
    maze:removeWall(current, next)
--      Node.addChild(node,Node.new(next, 0))
--    until recursiveBacktrack(maze, next, visited, node.children[#(node.children)])
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