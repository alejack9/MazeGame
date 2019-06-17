
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

Task = {}
function Task.new(node, prevTask, nextTask)
  local obj = obj or {}
  obj.prevTask = prevTask
  obj.nextTask = nextTask
  obj.coroutine = coroutine.create(go)
  obj.node = node
  setVisited(node)
  return obj
end

function setVisited (node)
  node.visited = true
  node.cell.status = "CIRCULAR_VISITED"
end

function orchestrator(startNode, lastNode)
  local task = Task.new(startNode)
  while not res do 
    _,task,res = coroutine.resume(task.coroutine, task, lastNode)
    coroutine.yield(res)
  end
end


function go(task, finish)

  if task.node == finish then 
    coroutine.yield(nil, true) 
  end
  --coroutine.yield(task, false)

--  if task.nextTask then
--    coroutine.resume(task.nextTask.coroutine, task.nextTask, finish) 
--    --coroutine.yield(task.nextTask, false)
--  end

  local children = getChildren(task.node)

  if #children == 0 then 
    task.prevTask.nextTask = task.nextTask
    task.nextTask.prevTask = task.prevTask
    coroutine.yield(task.nextTask, false)
  end
  local tasks = {}
  table.insert( tasks, Task.new(children[1], task.prevTask))
-- TOREFACTOR
  if task.prevTask then
    task.prevTask.nextTask = tasks[1]
    for i = 2, #children do
      table.insert(tasks, Task.new(children[i], tasks[i-1]))
      tasks[i-1].nextTask = tasks[i]
    end
    task.nextTask.prevTask = tasks[#children]
    tasks[#children].nextTask = task.nextTask
    --coroutine.yield(coroutine.resume(task.nextTask.coroutine, task.nextTask, finish))
    coroutine.yield(task.nextTask, false)
  else
    for i = 2, #children do
      table.insert(tasks, Task.new(children[i], tasks[i-1]))
      tasks[i-1].nextTask = tasks[i]
    end
    tasks[#children].nextTask = tasks[1]
    tasks[1].prevTask = tasks[#children]
    --coroutine.yield(coroutine.resume( tasks[1].coroutine, tasks[1], finish ))
    coroutine.yield(tasks[1], false)
  end
end


return orchestrator