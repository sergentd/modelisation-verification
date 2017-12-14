local Petrinet = require "petrinet"

return function (n)
  local result = Petrinet.create ()
  for i = 1, n do
    local id = tostring (i)
    result ["fork-"     .. id] = result:place (true )
    result ["thinking-" .. id] = result:place (true )
    result ["waiting-"  .. id] = result:place (false)
    result ["eating-"   .. id] = result:place (false)
  end
  for i = 1, n do
    local id   = tostring (i)
    local next = tostring (i < n and i + 1 or 1)
    result ["t1-" .. id] = result:transition {
      -result ["fork-"     .. id],
      -result ["thinking-" .. id],
       result ["waiting-"  .. id],
    }
    result ["t2-" .. id] = result:transition {
      -result ["waiting-" .. id  ],
      -result ["fork-"    .. next],
       result ["eating-"  .. id  ],
    }
    result ["t3-" .. id] = result:transition {
      -result ["eating-"   .. id  ],
       result ["fork-"     .. id  ],
       result ["fork-"     .. next],
       result ["thinking-" .. id  ],
    }
  end
  return result
end
