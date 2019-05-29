
function solve( start, finish, graph, cols )
    local stack_list = {
        {
            f = 0 + start.h,
            c = coroutine.create( doStep )
        }
    }

    local isFinished = coroutine.resume( stack_list[1].c, 0, start, finish, graph, cols)

    while not isFinished do
        _,isFinished = coroutine.resume(stack_list[1].c)
        table.sort( stack_list, function ( a, b ) return a.f < b.f end )
    end

end


function doStep (g, current, finish, graph, cols)

    current.visited = true
  
    if current == finish then 
      coroutine.yield(true) end
  
    local children = getChildren(cols, current)
  
    if #children == 0 then coroutine.yield(false) end
  
    if #children == 1 then 
        coroutine.yield( false )
        doStep(g + 1, children[1], finish, graph, cols)
    end

    coroutine.yield( fork(g + 1, children, finish, graph, cols) )
  end
  
  
  function fork(g, children, finish, graph, cols) 
    for _,child in pairs(children) do
      table.insert( threadList, 1, {
          f = g + graph.nodes[graph:positionToIndex(cols, child)].h,
          c = coroutine.create( doStep )
      })
      if coroutine.resume(threadList[1], g, child, finish, graph, cols) then
        return true
      end
    end
    return false
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