function getChildren( node )
  local toReturn = {}
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
  node.cell.status["CIRCULAR_VISITED"] = true
end

function orchestrator(startNode, lastNode)
  local task = Task.new(startNode)
  task.prevTask = task
  task.nextTask = task
  local res = false
  while not res do 
    _,task,res = coroutine.resume(task.coroutine, task, lastNode)
    coroutine.yield(res)
  end
end


function go(task, finish)
  if task.node == finish then coroutine.yield(nil, true) end

  local children = getChildren(task.node)
  if #children == 0 then 
    task.prevTask.nextTask = task.nextTask
    task.nextTask.prevTask = task.prevTask
    coroutine.yield(task.nextTask, false)
  end

  local tasks = {}
  table.insert( tasks, Task.new(children[1], task.prevTask))
  for i = 2, #children do
    table.insert(tasks, Task.new(children[i], tasks[i-1]))
    tasks[i-1].nextTask = tasks[i]
  end

  task.prevTask.nextTask = tasks[1]
  task.nextTask.prevTask = tasks[#children]
  tasks[#children].nextTask = task.nextTask
  coroutine.yield(task.nextTask, false)
end

return orchestrator