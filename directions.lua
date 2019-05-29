t = {
  ["up"]    = { -1  ,   0  },
  ["left"]  = { 0   ,   -1 },
  ["down"]  = { 1   ,   0  },
  ["right"] = { 0   ,   1  }
}
f = function(k)
  if k == "left" then return "right" elseif k == "right" then return "left" elseif k == "up" then return "down" elseif k == "down" then return "up" end
end

return {t,f}