local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.p1 = result:place (true )
result.p2 = result:place (false)
result.p3 = result:place (true )
result.t1 = result:transition {
  -result.p1,
   result.p1,
   result.p2,
}
result.t2 = result:transition {
  -result.p2,
   result.p3,
}
result.t3 = result:transition {
  -result.p3,
}

return result
