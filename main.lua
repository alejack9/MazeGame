math.randomseed(os.time())
local Maze = require('maze')
local solver = require('a-star-solver')
local Stack = require('stack')
local Graph = require('graph')
local directions , opposite = unpack(require('directions'))
local cSolver = require("circular-solver")
require('colors')

prevs = Stack:new()
showMaze = true

keys = {
  ["return"] = function() resolve = not resolve end,
  ["escape"] = function() exit() end,
  ["r"] = function() start() end,
  ["v"] = function() showMaze = not showMaze end,
  ["c"] = function() c_resolve = not c_resolve end,
  __index = function(t, k)
    if maze.current == maze.last and not maze.keyPos.hasKey then return function() end end
    k = (k == 'a' and 'left' or (k == 'd' and 'right' or (k == 's' and 'down' or (k == 'w' and 'up' or k))))
    if k ~= 'left' and k ~= 'right' and k ~= 'down' and k ~= 'up' then
      return function() end
    end
    return function()
      local valid, key = unpack(maze:move(k))
      if valid then
        if k == opposite(prevs:top()) then
          prevs:pop()
          steps["user"] = steps["user"] - 1;
        else
          prevs:push(k)
          steps["user"] = steps["user"] + 1
        end
        if key then prevs:clear() end
      end
    end
  end
}
setmetatable(keys, keys)

function love.keypressed(k)
  keys[k]()
end

function parseArgs(args)
  for i , arg in pairs(args) do
    if arg == "-debug"  then require("mobdebug").on(); require("mobdebug").coro(); require("mobdebug").start()
    elseif arg == "-c"  then
      COLS = tonumber(args[i+1])
      if COLS < 2 then exit('Minimum Colums: 2') end
    elseif arg == "-r"  then
      ROWS = tonumber(args[i+1])
      if ROWS < 2 then exit('Minimum Rows: 2') end
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
  
  ROWS = ROWS or 30
  COLS = COLS or math.ceil(ROWS * (MAZE_WIDTH / WINDOW_HEIGHT))
  
  setRandoms()

  PIERCE_PERCENTAGE = PIERCE_PERCENTAGE or 0.5
  
  width = MAZE_WIDTH / COLS
  height = WINDOW_HEIGHT / ROWS
end

function setRandoms()
  START_ROW , START_COL = math.random(1, ROWS) , math.random(1, COLS)
--  START_ROW , START_COL = 1,1
--  START_ROW , START_COL = ROWS/2,COLS/2
  LAST_ROW , LAST_COL = math.random(1, ROWS) , math.random(1, COLS)
--  LAST_ROW , LAST_COL = ROWS, COLS

  keypos = {}
  repeat
    keyPos = { math.random(1,ROWS),math.random(1,COLS) }
  until keyPos[1] == START_ROW and keyPos[2] == START_COL
--  keyPos = { ROWS/2, COLS/2 }
end

function love.load(args)
  love.graphics.setBackgroundColor(colors.BACKGROUND)
  INFO_WIDTH = 200
  parseArgs(args)
  setParams()
  start()
  drawWindow(MAZE_WIDTH + INFO_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
end


function love.update(dt)
  love.timer.sleep(1/60 - dt)
end

function start()
  maze = Maze:new(ROWS, COLS, START_ROW, START_COL, LAST_ROW, LAST_COL)

  setRandoms()
  
  maze:setKey(unpack(keyPos))
  maze:pierce(PIERCE_PERCENTAGE)

  graph = Graph:new()
  local function pitagora(current, target)
    return math.sqrt(
      math.pow(
        math.abs(current.col - target.col), 2
      ) +
    math.pow(
        math.abs(current.row - target.row), 2
      )
    )
  end
  local dijkstra = function() return 1 end
  graph:build(maze, maze.start)
--  graph:build(maze, maze.start, nil, pitagora)
--  graph:build(maze, maze.start, nil, dijkstra)
--  graph:build(maze, maze.start, pitagora)
--  graph:build(maze, maze.start, pitagora, dijkstra)
--  graph:build(maze, maze.start, pitagora, pitagora)
--  graph:build(maze, maze.start, dijkstra)
--  graph:build(maze, maze.start, dijkstra, pitagora)
--  graph:build(maze, maze.start, dijkstra, dijkstra)

  toKey = coroutine.create(solver)
  toExit = coroutine.create(solver)

  solvedToExit = false
  continueToExit = true

  solvedToKey = false
  continueToKey = true

  c_solved = false

  _,solvedToKey,continueToKey =
    coroutine.resume(toKey, graph.nodes[maze.start.row][maze.start.col], 
      graph.nodes[maze.keyPos.row][maze.keyPos.col], graph,
      function (node) return node.attrToKey end
    )

  _,solvedToExit,continueToExit =
    coroutine.resume(toExit, graph.nodes[maze.keyPos.row][maze.keyPos.col],
      graph.nodes[maze.last.row][maze.last.col], graph,
      function (node) return node.attrToExit end
    )

  cs = coroutine.create( cSolver )
  
  steps = { user = 0, solver = 0 }
  resolve = false
  c_resolve = false
  done = { key = false, exit = false }
end


function drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
  FULLSCREEN = FULLSCREEN and true or false
  if FULLSCREEN then love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true, fullscreentype = "desktop"})
  else love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT) end
end


function love.draw()
  love.graphics.setColor(unpack(colors.INFO))
  love.graphics.printf("User steps: " .. steps["user"], MAZE_WIDTH, 10, INFO_WIDTH - 10, "left", 0, 1, 1, -10)
  love.graphics.printf("Solver steps: " .. steps["solver"], MAZE_WIDTH, 30, INFO_WIDTH - 10, "left", 0, 1, 1, -10)

  if resolve then
    if (continueToExit or not solvedToExit) then
      _,solvedToExit,continueToExit = coroutine.resume( toExit )
    end
    if (continueToKey or not solvedToKey) then
      _,solvedToKey,continueToKey = coroutine.resume( toKey )
    end
  end

  if c_resolve and not c_solved then
    _,c_solved = coroutine.resume( cs, graph.nodes[maze.start.row][maze.start.col], graph.nodes[maze.last.row][maze.last.col])
  end

  if showMaze then
    maze:draw(width, height)
  else
    graph:draw(width, height)
  end
  
  if c_solved then
    printSolution(maze.last, function(node) return node end, colors.CIRCULARPATH)
  end
  if solvedToKey then
    printSolution(maze.keyPos, function(node) return node.attrToKey end, colors.TOKEYPATH, true)
    done.key = true
  end
  if solvedToExit then
    printSolution(maze.last, function(node) return node.attrToExit end, colors.TOEXITPATH, true)
    done.exit = true
  end
    
  if maze.current.isLast and maze.current.open then
    love.graphics.setColor(unpack(colors.INFO))
    love.graphics.printf("YOU WIN!", MAZE_WIDTH, 50, INFO_WIDTH - 10, "left", 0, 1, 1, -10)
  end
end

function printSolution(target, getAttributes, color, astar)
  local w = love.graphics.getLineWidth()
  love.graphics.setLineWidth( 3 )
  love.graphics.setColor(color)
  local current = graph.nodes[target.row][target.col]
  while getAttributes(current).parent do
    love.graphics.line(current.cell.col * width - width/2, current.cell.row * height - height/2,
    getAttributes(current).parent.cell.col * width - width/2, getAttributes(current).parent.cell.row * height - height/2)
    current = getAttributes(current).parent
     if astar and (target == maze.keyPos and not done.key or target == maze.last and not done.exit) then 
       steps["solver"] = steps["solver"] + 1
     end
  end
  love.graphics.setLineWidth( w )
end

function exit(exitError)
  print(exitError or '')
  os.exit(exitError and -1 or 0)
end
