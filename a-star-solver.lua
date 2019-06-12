function solve( start, finish, graph, getAttributes )
  local OPEN = {}
  local CLOSE = {}
  setOpen(start, OPEN, finish)
  getAttributes(start).g = 0
  local _finish = finish
  local _attributes = getAttributes

  _solve = function (OPEN, CLOSE, finish, attributes)
    local current = OPEN[1]
    if current == finish then
      coroutine.yield( true, false )
    end
    for _,child in pairs(getNotClosedChildren(current, graph, CLOSE)) do
      if not isOpen(child, OPEN) then
        setOpen(child, OPEN, finish)
        handleChild(child, current, attributes)
      elseif attributes(child).f > attributes(child).h + attributes(current).g + 1 then
        handleChild(child, current, attributes)
      end
    end
    setClose(table.remove( OPEN, 1 ),CLOSE, finish)
    if not isOpenSetEmpty(OPEN) then
      table.sort( OPEN, function (a, b)
          return attributes(a).f < attributes(b).f 
        end
      )
      coroutine.yield( false, true )
      _solve(OPEN, CLOSE, finish, attributes)
    else
      coroutine.yield( false, false )
    end
  end

  return _solve(OPEN, CLOSE, _finish, _attributes)
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

function handleChild (child, parent, attributes)
  attributes(child).parent = parent
  attributes(child).g = attributes(parent).g + 1
  attributes(child).f = attributes(child).h + attributes(child).g
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