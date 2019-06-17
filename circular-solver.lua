
function getChildren( node )
  toReturn = {}
  for _,child in pairs(node.children) do 
    if not child.visited then
       table.insert( toReturn, child )
       child.parent = node
    end
  end
  return toReturn
end

--Task = { prev = coroutine.create(nil), next = coroutine.create(nil), current = coroutine.create(nil) }
Task = {}
function Task.new(node, prevTask, nextTask)
  local obj = obj or {}
  obj.prevTask = prevTask
  obj.nextTask = nextTask
  obj.coroutine = coroutine.create(go)
  obj.node = node
  setVisited(node)
--  setmetatable(obj, Task)
--  self.__index = Task
  return obj
end

function setVisited (node)
  if node == nil then
    print("Ciao")
  end
  node.visited = true
  node.cell.status = "CIRCULAR_VISITED"
end

--function setup (node, prevTask, nextTask, finish)
----  setVisited(node)
----  local task = { current = coroutine.create(go), prev = prevTask, next = nextTask }
--  coroutine.yield()
--  coroutine.resume(task.current, node, task, finish)
--end

function setup(startNode, lastNode)
  local task = Task.new(startNode)
  task.prevTask = nil
  task.nextTask = nil
  res = false
  while not res do 
    _,task,res = coroutine.resume(task.coroutine, task, lastNode)
    if task == nil then
      print("Ciao")
    end
    print(tostring(task))
    coroutine.yield(res)
  end
end


function go(task, finish)

  if task.node == finish then 
    coroutine.yield(task, true) 
  end
  coroutine.yield(task, false)

  if task.nextTask then
    coroutine.resume(task.nextTask.coroutine, task.nextTask, finish) 
  end

  local children = getChildren(task.node)

  if #children == 0 then 
    task.prevTask.nextTask = task.nextTask
    task.nextTask.prevTask = task.prevTask
    coroutine.yield(task.nextTask, false)

  else
    local tasks = {}
    table.insert( tasks, Task.new(children[1], task.prevTask, nil))

    if task.prevTask then
      task.prevTask.nextTask = tasks[1]
      for i = 2, #children do
        table.insert(tasks, Task.new(children[i], tasks[i-1], nil))
        tasks[i-1].nextTask = tasks[i]
      end
      task.nextTask.prevTask = tasks[#children]
      tasks[#children].nextTask = task.nextTask
      coroutine.resume(task.nextTask.coroutine, task.nextTask, finish)
      -- coroutine.yield(task.nextTask, false)
    else
      if #children == 1 then
        task.node = children[1]
        go(task, finish)
      else
        for i = 2, #children do
          table.insert(tasks, Task.new(children[i], tasks[i-1], nil))
          tasks[i-1].nextTask = tasks[i]
        end
        tasks[#children].nextTask = tasks[1]
        tasks[1].prevTask = tasks[#children]
        coroutine.resume( tasks[1].coroutine, tasks[1], finish )
        --coroutine.yield(tasks[1], false)
      end
    end
  end
  print("Fine")
end

--function go (node, next, finish)
--  setVisited(node)
--  if node == finish then coroutine.yield( )
--  else
--    coroutine.yield()
--    if next then
--      coroutine.resume( next )
--      -- local _,res,nextnext = resume(next)
--      -- if not res then
--      --     next = nextnext
--      -- end
--    end
--    local children = getChildren(node)
--    if #children == 0 then
--      coroutine.yield(  )
--    else
--      if #children == 1 then
--        go(children[1], next, finish)
--      else
--        local c1 = coroutine.create( setup )
--        coroutine.resume( c1, children[#children], next, finish)
--        if #children == 3 then
--          local c2 = coroutine.create( setup )
--          coroutine.resume( c2, children[2], c1, finish)
--          go(children[1], c2, finish)
--        else
--          go(children[1], c1, finish)
--        end
--      end
--    end
--  end
--end
--function setup (node, next, finish)
--    setVisited(node)
--    local myNode = node
--    local myNext = next
--    coroutine.yield( )
--    go(myNode, myNext, finish)
--end

return setup