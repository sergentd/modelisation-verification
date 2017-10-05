local Petrinet = require "petrinet"

return function (n)
  local result = Petrinet.create ()
  for i = 1, n do
    local id = tostring (i)
    result ["fork-"     .. id] = result:place (1)
    result ["thinking-" .. id] = result:place (1)
    result ["waiting-"  .. id] = result:place (0)
    result ["eating-"   .. id] = result:place (0)
  end
  for i = 1, n do
    local id   = tostring (i)
    local next = tostring (i < n and i + 1 or 1)
    result ["t1-" .. id] = result:transition {
      result ["fork-"     .. id] - 1,
      result ["thinking-" .. id] - 1,
      result ["waiting-"  .. id] + 1,
    }
    result ["t2-" .. id] = result:transition {
      result ["waiting-" .. id  ] - 1,
      result ["fork-"    .. next] - 1,
      result ["eating-"  .. id  ] + 1,
    }
    result ["t3-" .. id] = result:transition {
      result ["eating-"   .. id  ] - 1,
      result ["fork-"     .. id  ] + 1,
      result ["fork-"     .. next] + 1,
      result ["thinking-" .. id  ] + 1,
    }
  end
  return result
end
