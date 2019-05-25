directions = require("directions")

Graph = {
    nodes = {}
}

function Graph.new(self)
    local obj = {
        nodes = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Graph.tostring(self) 
    local toReturn = ""

    for _,node in pairs(self.nodes) do
        toReturn = toReturn..node.cell:tostring().."\n"
        toReturn = toReturn.."Children : "
        for _,child in pairs(node.children) do
            toReturn = toReturn..child:tostring().." "
        end
        toReturn = toReturn.."\n"
    end
    return toReturn
end


function Graph.build(self, maze, current )
    table.insert( self.nodes, {cell = current, 
                          children = maze:getNeighborsWithoutWalls(current)
                        })
    if maze:isValid(current.row + directions["right"][1], current.col + directions["right"][2]) then
        next = maze:getCell(current.row + directions["right"][1], current.col + directions["right"][2])
        self:build(maze, next)
    elseif maze:isValid(current.row + directions["down"][1], 1) then
        next = maze:getCell(current.row + directions["down"][1], 1)
        self:build(maze, next)
    end
end

return Graph