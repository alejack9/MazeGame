math.randomseed(os.time())
local Maze = require('maze')
local solver = require('a-star-solver')
local Stack = require('stack')
local Graph = require('graph')
local directions , opposite = unpack(require('directions'))
require('colors')

prevs = Stack:new()
showMaze = true

keys = {
  ["escape"] = function() exit() end,
  ["v"] = function() showMaze = not showMaze end,
  __index = function() return function() end end
}
setmetatable(keys, keys)

function love.keypressed(k)
  keys[k]()
end

function parseArgs(args)
  for i , arg in pairs(args) do
    if arg == "-debug"  then require("mobdebug").on(); require("mobdebug").coro(); require("mobdebug").start() end
  end
end

FULLSCREEN = true
maxW, maxH = love.window.getDesktopDimensions()
MAZE_WIDTH = maxW
WINDOW_HEIGHT = maxH

function setParams()
  ROWS = math.random(5,80)
  COLS = math.ceil(ROWS * (MAZE_WIDTH / WINDOW_HEIGHT))
  setRandoms()
end

function setRandoms()
  START_ROW , START_COL = math.random(1, ROWS) , math.random(1, COLS)
  LAST_ROW , LAST_COL = math.random(1, ROWS) , math.random(1, COLS)

  keypos = {}
  repeat
    keyPos = { math.random(1,ROWS),math.random(1,COLS) }
  until keyPos[1] == START_ROW and keyPos[2] == START_COL
  
  width = MAZE_WIDTH / COLS
  height = WINDOW_HEIGHT / ROWS
  PIERCE_PERCENTAGE = math.random(0, 1) / math.random(1, 100)

end

function love.mousemoved()
    exit()
end

function love.load(args)
  love.mouse.setVisible(false)
  love.graphics.setBackgroundColor(colors.BACKGROUND)
  INFO_WIDTH = 0
  parseArgs(args)
  setParams()
  start()
  drawWindow(MAZE_WIDTH + INFO_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
end

function start()
  setParams()
  maze = Maze:new(ROWS, COLS, START_ROW, START_COL, LAST_ROW, LAST_COL)

  setRandoms()
  
  maze:setKey(unpack(keyPos))
  maze:pierce(PIERCE_PERCENTAGE)

  graph = Graph:new()
  graph:build(maze, maze.start)

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

  steps = { user = 0, solver = 0 }
  resolve = true
  done = { key = false, exit = false }
end


function drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, FULLSCREEN)
  FULLSCREEN = FULLSCREEN and true or false
  if FULLSCREEN then love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true, fullscreentype = "desktop"})
  else love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT) end
end


function love.draw()
  if restart then
    restart = false
    start()
  end
  
  if solvedToExit and solvedToKey then
    love.timer.sleep(2.5)
    restart = true
    return
  end
  
  if resolve then
    if (continueToExit or not solvedToExit) then
      _,solvedToExit,continueToExit = coroutine.resume( toExit )
    end
    if (continueToKey or not solvedToKey) then
      _,solvedToKey,continueToKey = coroutine.resume( toKey )
    end
  end

  if showMaze then
    maze:draw(width, height)
  else
    graph:draw(width, height)
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
