AvlNode = {}
AvlNode.__index=AvlNode

AvlNode.new = function ( _data, _value, _left, _right)
    return setmetatable({
        data = _data,
        value = _value,
        left = _left,
        right = _right,
    }, AvlNode)
end


return AvlNode