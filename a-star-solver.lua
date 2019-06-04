
--[[function solve( start, finish, graph, cols )
    local stack_list = {
        {
            f = 0 + graph.nodes[graph:positionToIndex(cols, start)].hE,
            c = coroutine.create( doStep )
        }
    }

    local _,isFinished,toContinue = coroutine.resume( stack_list[1].c, 0, start, finish, graph, cols)

    while not isFinished do
        _,isFinished,toContinue = coroutine.resume(stack_list[1].c)
        if not toContinue then
          table.remove( stack_list, 1)
        end
        table.sort( stack_list, function ( a, b ) return a.f < b.f end )
        coroutine.yield( isFinished )
    end

end]]


function solve( start, finish, graph, mazeCols, heuristic )

  local OPEN = {}
  local CLOSE = {}
  setOpen(start, OPEN)
  start.g = 0
  local _finish = finish
  local _heuristic = heuristic

  _solve = function (OPEN, CLOSE, finish, heuristic)
    local current = OPEN[1]--table.remove( OPEN, 1)
    if current == finish then
      coroutine.yield( true, false ) 
    end
    for _,child in pairs(getNotClosedChildren(current, graph, mazeCols, CLOSE)) do
      --child.parent = current
      --if child.hE == 0 then coroutine.yield(true,false) end
      if not isOpen(child, OPEN) then
         setOpen(child, OPEN)
         child.parent = current
         child.g = current.g + 1
         child.f = heuristic(child) + child.g
      elseif child.f > heuristic(child) + current.g + 1 then
        child.parent = current
        child.g = current.g + 1
        child.f = heuristic(child) + child.g
      end
    end
    setClose(table.remove( OPEN, 1 ),CLOSE)
    if not isOpenSetEmpty(OPEN) then
      table.sort( OPEN, function (a, b)
        --if a.f == b.f then
        --  return a.hE < b.hE
        --else 
          return a.f < b.f 
        end
        --end 
      )
      coroutine.yield( false, true )
      _solve(OPEN, CLOSE, finish, heuristic)
    else
      coroutine.yield( false, false )
    end
  end

  return _solve(OPEN, CLOSE, _finish, _heuristic)
end


function getNotClosedChildren( node, graph, mazeCols, CLOSE)
  toReturn = {}
  for _,child in pairs(node.children) do
    --if not (graph.nodes[graph:positionToIndex(mazeCols, child)].status == "CLOSED") then
    local toAdd = true
    for _,n in pairs(CLOSE) do
      if child == n.cell then
        toAdd = false
        break
      end
    end
    if toAdd then 
      table.insert( toReturn, graph.nodes[graph:positionToIndex(mazeCols, child)] )
    end
   -- end
  end
  return toReturn
end

function isOpen ( node, OPEN )
  for _,n in pairs(OPEN) do
    if node == n then
      return true
    end
  end
  return false
end

function setOpen ( node, OPEN )
  node.cell.status = "OPEN"
  table.insert( OPEN, node )
end

function setClose (node, CLOSE)
  node.cell.status = "CLOSED"
  table.insert( CLOSE, node )
end

function isOpenSetEmpty (OPEN )
  return #OPEN == 0
end



--[[
function doStep (g, current, finish, graph, cols)

    current.visited = true
  
    if current == finish then 
      coroutine.yield(true, false) end
  
    local children = getChildren(cols, current)
  
    if #children == 0 then coroutine.yield(false, false) end
  
    if #children == 1 then 
        coroutine.yield( false, true )
        doStep(g + 1, children[1], finish, graph, cols)
    end

    coroutine.yield( fork(g + 1, children, finish, graph, cols) )
  end
  
  
  function fork(g, children, finish, graph, cols) 
    for _,child in pairs(children) do
      table.insert( stack_list, 1, {
          f = g + graph.nodes[graph:positionToIndex(cols, child)].hE,
          c = coroutine.create( doStep )
      })
      if coroutine.resume(stack_list[1].c, g, child, finish, graph, cols) then
        return true, false
      end
    end
    return false, true
  end

function getChildren ( cols, cell )
    local toReturn = {}
    local all = graph.nodes[graph:positionToIndex(cols, cell)].children
    for _,child in pairs(all) do
        if not child.visited then
            table.insert( toReturn, child )
        end
    end
    return toReturn
end
]]
return solve

