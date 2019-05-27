math.randomseed(os.time())
local Maze = require('maze')
local solver = require('maze-solver')
local Stack = require('stack')
local Graph = require('graph')

function parseArgs(args)
  for i , arg in pairs(args) do
    if arg == "-debug"  then require("mobdebug").on(); require("mobdebug").coro(); require("mobdebug").start()
    elseif arg == "-c"  then COLS = tonumber(args[i+1]); if COLS < 2 then exit('Minimum Colums: 2') end
    elseif arg == "-r"  then ROWS = tonumber(args[i+1]); if ROWS < 2 then exit('Minimum Rows: 2') end
    elseif arg == "-f"  then FULLSCREEN = true
    elseif arg == "-mh" then WINDOW_HEIGHT = tonumber(args[i+1])
    elseif arg == "-mw" then MAZE_WIDTH = tonumber(args[i+1])
    elseif arg == "-p"  then PIERCE_PERCENTAGE = tonumber(args[i+1])
    end
  end
end

function setParams()
  FULLSCREEN = FULLSCREEN or false
  local maxW, maxH = love.window.getDesktopDimensions()
  MAZE_WIDTH = FULLSCREEN and maxW - INFO_WIDTH or MAZE_WIDTH and MAZE_WIDTH or 800
  WINDOW_HEIGHT = FULLSCREEN and maxH or WINDOW_HEIGHT and WINDOW_HEIGHT or 800
  ROWS = ROWS or 10
  COLS = COLS or math.ceil(ROWS * (MAZE_WIDTH / WINDOW_HEIGHT))
  
  PIERCE_PERCENTAGE = PIERCE_PERCENTAGE or 0.25
  
  width = MAZE_WIDTH / COLS
  height = WINDOW_HEIGHT / ROWS
  
  START_ROW , START_COL = 4 , 4
  LAST_ROW , LAST_COL = ROWS , COLS

end

function love.load(args)
  INFO_WIDTH = 200
  
  parseArgs(args)
  
  setParams()
  
  start()

  drawWindow(MAZE_WIDTH + INFO_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
end


function love.update(dt)
  love.timer.sleep(1/30 - dt)
end

function start()
  maze = Maze:new(ROWS, COLS, START_ROW, START_COL, LAST_ROW, LAST_COL)

  recursiveBacktrack(maze, maze:getCell(1, 1))

  local keyPos
  repeat
    keyPos = { math.random(1,ROWS),math.random(1,COLS) }
  until keyPos[1] ~= START_ROW and keyPos[2] ~= START_COL
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
  ["escape"] = function() exit() end,
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
  if maze.current.isLast and maze.current.open then
    love.graphics.setColor(10 / 255, 10 / 255, 10 / 255, 1)
    love.graphics.rectangle("fill", 0, 0, MAZE_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("YOU WIN!", 0, WINDOW_HEIGHT / 2, MAZE_WIDTH / 2.5, "center", 0, 2.5, 5)
  end
end

function exit(exitError)
  print(exitError or '')
  os.exit(exitError and -1 or 0)
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