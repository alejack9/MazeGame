function solve( current, last, graph )
    
end

function inside (currentNode, next, graph)
    currentNode.visited = true
    coroutine.yield( )
    local children = getChildrenNotVisited(currentNode, graph)
    if #children == 0 then error("aaaa") end
    if #children == 1 then
        coroutine.resume( next )
        inside(children[1], next)
    else
        local coroutines = {
            __newindex = function (cors, pos, children)
                cors[pos] = coroutine.create(inside)
                coroutine.resume( cors[pos], children[pos], cors[(pos-1) % #coroutines], graph)
            end
        }
        setmetatable(coroutines, coroutines)
        coroutines[#children] = children
        local coroutines = {coroutine.create( inside )}
        for i = 2, #children do
            table.insert( coroutines, coroutine.create( inside ))
            coroutine.resume( cor, children[i], coroutines[(i-1) % #coroutines], graph)
        end
        -- resume per settaggio parametri
        coroutine.resume( coroutines[1], children[1], coroutines[#coroutines], graph)
        -- resume per avvio coroutine
        coroutine.resume( coroutines[1] )
    end
end

table.filter = function(t, filterIter)
    local out = {}
    for k, v in pairs(t) do
        if filterIter(v, k, t) then table.insert(out,v) end
    end
    return out
end

function getChildrenNotVisited( node, graph )
    table.filter(node.children, function (n) return not n.visited end)
end