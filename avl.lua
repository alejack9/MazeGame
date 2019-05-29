
require("avl-node")

AVL = {}
AVL.__index = AVL

AVL.new = function (_root) 
  return setmetatable({
      root = _root
      }, AVL)
end

AVL.height = function (avl)
  if (avl == nil) then return 0 end
  return 1 + math.max( AVL.height(avl.root.left), AVL.height(avl.root.right))
end

AVL.print = function (avl)
  if(avl == nil) then return
  else
    AVL.print(avl.root.left)
    print(avl.root.data)
    AVL.print(avl.root.right)
  end
end

AVL.listOf = function (avl) 
  local _list = {}
  local _listOf
  _listOf = function ( _avl )
    if _avl == nil then return
    else 
      _listOf(_avl.root.left)
      table.insert( _list, {_avl.root.data, _avl.root.value})
      _listOf(_avl.root.right)
    end
  end
  _listOf(avl)
  return _list
end


AVL.fromOrderedList = function (list)

  local _fromList
  _fromList = function ( i, j )
    if j <= i then return nil
    else
      local m = math.floor( (i + j - 1) / 2 ) + 1
      local v = list[m]
      if v == nil then return nil end
      return AVL.new(
        AvlNode.new(
          v[1], v[2], _fromList(i,m - 1), _fromList(m, j)
        ))
    end
  end

  return _fromList(0, #list + 1)
end

AVL.fromList = function(list)
  table.sort( list, function(a,b) return a[2] < b[2] end )
  return AVL.fromOrderedList(list)
end

AVL.balance = function (avl)
  return AVL.fromList(avl:listOf())
end 

AVL.add = function(avl, node)
  local _list = avl:listOf()
  table.insert( _list, {node.data, node.value})
  return AVL.fromList(_list)
end

return AVL