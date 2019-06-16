
function setVisited (node)
    node.visited = true
    node.cell.status = "OPENTOEXIT"
end

function getChildren( node )
    toReturn = {}
    for _,child in pairs(node.children) do 
        if not child.visited then table.insert( toReturn, child ) end
    end
    return toReturn
  end

function setup (node, next, finish)
    setVisited(node)
    local myNode = node
    local myNext = next
    coroutine.yield( )
    go(myNode, myNext, finish)
end

function go (node, next, finish)
    setVisited(node)
    if node == finish then coroutine.yield( )
    else
        --coroutine.yield(  )
        if next then
            coroutine.resume( next )
            -- local _,res,nextnext = resume(next)
            -- if not res then
            --     next = nextnext
            -- end
        end
        local children = getChildren(node)
        if #children == 0 then
            coroutine.yield(  )
        else
            if #children == 1 then
                go(children[1], next, finish)
            else
                local c1 = coroutine.create( setup )
                coroutine.resume( c1, children[#children], next, finish)
                if #children == 3 then
                    local c2 = coroutine.create( setup )
                    coroutine.resume( c2, children[2], c1, finish)
                    go(children[1], c2, finish)
                else
                    go(children[1], c1, finish)
                end
            end
        end
    end
end

return setup