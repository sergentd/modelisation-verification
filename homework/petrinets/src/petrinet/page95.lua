local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.p1 = result:place (1)
result.t1 = result:transition {
  result.p1 - 1,
  result.p1 + 3,
}

return result
