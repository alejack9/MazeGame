function solve( start, finish, graph, heuristic, setParentFn )
  local OPEN = {}
  local CLOSE = {}
  setOpen(start, OPEN, finish)
  start.g = 0
  local _finish = finish
  local _heuristic = heuristic
  local setParent = setParentFn

  _solve = function (OPEN, CLOSE, finish, heuristic, setParent)
    local current = OPEN[1]
    if current == finish then
      coroutine.yield( true, false )
    end
    for _,child in pairs(getNotClosedChildren(current, graph, CLOSE)) do
      if not isOpen(child, OPEN) then
        setOpen(child, OPEN, finish)
        handleChild(child, current, setParent, heuristic)
      elseif child.f > heuristic(child) + current.g + 1 then
        handleChild(child, current, setParent, heuristic)
      end
    end
    setClose(table.remove( OPEN, 1 ),CLOSE, finish)
    if not isOpenSetEmpty(OPEN) then
      table.sort( OPEN, function (a, b)
          return a.f < b.f 
        end
      )
      coroutine.yield( false, true )
      _solve(OPEN, CLOSE, finish, heuristic, setParent)
    else
      coroutine.yield( false, false )
    end
  end

  return _solve(OPEN, CLOSE, _finish, _heuristic, setParent)
end


function getNotClosedChildren( node, graph, CLOSE)
  toReturn = {}
  for _,child in pairs(node.children) do
    local toAdd = true
    for _,n in pairs(CLOSE) do
      if child == n then
        toAdd = false
        break
      end
    end
    if toAdd then 
      table.insert( toReturn, child )
    end
  end
  return toReturn
end

function handleChild (child, parent, setParent, heuristic)
  setParent(child, parent)
  child.g = parent.g + 1
  child.f = heuristic(child) + child.g
end

function isOpen ( node, OPEN )
  for _,n in pairs(OPEN) do
    if node == n then
      return true
    end
  end
  return false
end

function setOpen ( node, OPEN, finish )
  if finish.cell == maze.keyPos then
    node.cell.status = "OPENTOKEY"
  else
    node.cell.status = "OPENTOEXIT"
  end
  table.insert( OPEN, node )
end

function setClose (node, CLOSE, finish)
  if finish.cell == maze.keyPos then
    node.cell.status = "CLOSEDTOKEY"
  else
    node.cell.status = "CLOSEDTOEXIT"
  end
  table.insert( CLOSE, node )
end

function isOpenSetEmpty (OPEN )
  return #OPEN == 0
end

return solve