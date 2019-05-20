math.randomseed(os.time())
local Maze = require('maze')
local Stack = require('stack')
require("maze-solver")


function love.load()
    --local windowSize = {1920, 1080}
    local windowSize = {800, 800}
    love.window.setMode(windowSize[1], windowSize[2])
    love.window.setFullscreen(true)
    -- rows = 78
    -- maze = Maze:new(rows, math.ceil(rows * 1.75))
    maze = Maze:new(50, 50)
    width = windowSize[1] / maze.cols
    height = windowSize[2] / maze.rows
    recursiveBacktrack(maze, maze:getCell(1, 1))
    maze.grid[1][1].walls.top = false
    maze.grid[maze.rows][maze.cols].walls.bottom = false

    -- Reset visited value for each cell 

    for i = 1, maze.rows do
        for j = 1, maze.cols do
        maze:getCell(i,j).visited = false
        end
    end


    -- Prepare solving

    start = {y = 1, x = 1}
    exit = {x = maze.cols, y = maze.rows}

    c = coroutine.create( Solver["doStep"] )

    step_stack = {start}
    step_index = 1
    isFinish = false

    resolve = false
end


function recursiveBacktrack(maze, current, stack)
    stack = stack or Stack:new(current)
    current.visited = true
    if stack:length() == 0 then
        return
    end
    local neighbors = maze:getNeighbors(current)
    if #neighbors == 0 then
        return recursiveBacktrack(maze, stack:pop(), stack)
    end
    local next = neighbors[math.random(1, #neighbors)]
    stack:push(next)
    maze:removeWall(current, next)
    recursiveBacktrack(maze, next, stack)
end

function love.keypressed(k)
	if k == 'return' then
		resolve = not resolve
    end
    if k == "escape" then
        love.event.push('quit')
    end
end

function love.draw()

    -- Draw Maze

    maze:draw(width, height)

    -- Solve

    if resolve and not isFinish and #step_stack > 0 then
        current = table.remove( step_stack, step_index)
        _,isFinish,neighbors = coroutine.resume( c, current, exit, maze)
        for _,n in pairs(neighbors) do
          table.insert( step_stack, step_index, n )
        end
        if #step_stack > 0 then
            step_index = (step_index % #step_stack) + 1
        end
      end
end
