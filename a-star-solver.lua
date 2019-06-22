function solve( start, finish, graph, getAttributes )
  local OPEN = {}
  local CLOSE = {}
  setOpen(start, OPEN, finish)
  getAttributes(start).g = 0
  local _finish = finish
  local _attributes = getAttributes
  return _solve(OPEN, CLOSE, _finish, _attributes)
end


function _solve (OPEN, CLOSE, finish, attributes)
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
    coroutine.yield( false, true )
    if not (#OPEN == 0) then
      table.sort( OPEN, function (a, b) return attributes(a).f < attributes(b).f end)
      _solve(OPEN, CLOSE, finish, attributes)
    end
  end

function getNotClosedChildren( node, graph, CLOSE)
  toReturn = {}
  for _,child in pairs(node.children) do
    local toAdd = true
    for _,n in pairs(CLOSE) do
      if not toAdd then break end
      if child == n then toAdd = false end
    end
    if toAdd then table.insert( toReturn, child ) end
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
    if node == n then return true
    end
  end
  return false
end

function setOpen ( node, OPEN, targetNode )
  if targetNode.cell == maze.keyPos then
    node.cell.status["OPENTOKEY"] = true
    node.cell.status["CLOSEDTOKEY"] = false
  else
    node.cell.status["OPENTOEXIT"] = true
    node.cell.status["CLOSEDTOEXIT"] = false
  end
  table.insert( OPEN, node )
end

function setClose (node, CLOSE, finish)
  if finish.cell == maze.keyPos then
    node.cell.status["CLOSEDTOKEY"] = true
    node.cell.status["OPENTOKEY"] = false
  else
    node.cell.status["CLOSEDTOEXIT"] = true
    node.cell.status["OPENTOEXIT"] = false
  end
  table.insert( CLOSE, node )
end


return solve