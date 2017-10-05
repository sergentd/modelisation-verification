local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.s1 = result:place (1)
result.s2 = result:place (1)
result.s3 = result:place (0)
result.s4 = result:place (0)
result.t  = result:transition {
  result.s1 - 1,
  result.s2 - 1,
  result.s3 + 1,
  result.s4 + 1,
}

return result
