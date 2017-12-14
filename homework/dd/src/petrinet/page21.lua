local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.s1 = result:place (true )
result.s2 = result:place (true )
result.s3 = result:place (false)
result.s4 = result:place (false)
result.t  = result:transition {
  -result.s1,
  -result.s2,
   result.s3,
   result.s4,
}

return result
