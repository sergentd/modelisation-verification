local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.p1 = result:place (true )
result.p2 = result:place (true )
result.p3 = result:place (false)
result.p4 = result:place (false)
result.p5 = result:place (false)
result.t1 = result:transition {
  -result.p1,
   result.p3,
}
result.t2 = result:transition {
  -result.p2,
   result.p4,
}
result.t3 = result:transition {
  -result.p2,
  -result.p3,
   result.p5,
}

return result
