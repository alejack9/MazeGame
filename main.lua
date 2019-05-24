math.randomseed(os.time())
local Maze = require('maze')
solver = require('maze-solver')
--local Stack = require('stack')
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  local WINDOW_WIDTH = 600
  local WINDOW_HEIGHT = 600
  local ROWS = 20
  local COLS = 20
  local PIERCE_PERCENTAGE = 0.1
--    local FULLSCREEN=true
--    local WINDOW_WIDTH = 1920
--    local WINDOW_HEIGHT = 1080
--    local ROWS = 100
--    local COLS = math.ceil(ROWS * 1.75)
  
    maze = Maze:new(ROWS, COLS)
    width = WINDOW_WIDTH / maze.cols
    height = WINDOW_HEIGHT / maze.rows
    
    recursiveBacktrack(maze, maze:getCell(1, 1))
    --recursiveBacktrackWithStack(maze, maze:getCell(1, 1))
    maze.grid[1][1].walls.top = false
    maze.grid[ROWS][COLS].walls.bottom = false
    
    maze:pierceMaze(PIERCE_PERCENTAGE)

    resolve = false

    drawWindow(WINDOW_WIDTH, WINDOW_HEIGHT, false)
    for _, rrow in ipairs(maze.grid) do for _,cell in ipairs(rrow) do cell.visited = false end end
    c = coroutine.create(solver)
    coroutine.resume(c, maze:getCell(1,1), maze:getCell(ROWS,COLS), maze)
    res = false
end

function Maze.pierceMaze(self, percentage)
  for i=1, math.ceil(percentage * self.rows * self.cols) do
      local row, col = math.random(2, self.rows - 1), math.random(2, self.cols - 1)
      local walls = {"bottom", "top", "right", "left"}
      local wall = walls[math.random(1, 4)]
      local nextRow, nextCol = row,col
      if wall == "bottom" then
          nextRow = nextRow + 1
      elseif wall == "top" then
          nextRow = nextRow - 1
      elseif wall == "left" then
          nextCol = nextCol - 1
      else
          nextCol = nextCol + 1
      end
      self:removeWall(self:getCell(row, col), self:getCell(nextRow, nextCol))
  end
end

function love.update(dt)
    love.timer.sleep(1/30 - dt)
end

function love.keypressed(k)
    if k == "return" then
        resolve = not resolve
    end
    if k == "escape" then
        love.event.push('quit')
    end
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