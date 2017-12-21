local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.p1 = result:place (true )
result.p2 = result:place (false)
result.p3 = result:place (false)
result.p4 = result:place (false)
result.t1 = result:transition {
  -result.p1,
   result.p1,
   result.p2,
}
result.t2 = result:transition {
  -result.p1,
   result.p3,
}
result.t3 = result:transition {
  -result.p2,
  -result.p3,
   result.p3,
   result.p4,
}
result.t4 = result:transition {
  -result.p3,
  -result.p4,
   result.p1,
}

return result
