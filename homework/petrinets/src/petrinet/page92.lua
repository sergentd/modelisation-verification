local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.p1 = result:place (1)
result.p2 = result:place (0)
result.p3 = result:place (0)
result.p4 = result:place (0)
result.t1 = result:transition {
  result.p1 - 1,
  result.p1 + 1,
  result.p2 + 1,
}
result.t2 = result:transition {
  result.p1 - 1,
  result.p3 + 1,
}
result.t3 = result:transition {
  result.p2 - 1,
  result.p3 - 1,
  result.p3 + 1,
  result.p4 + 1,
}
result.t4 = result:transition {
  result.p3 - 1,
  result.p4 - 1,
  result.p1 + 1,
}

return result
