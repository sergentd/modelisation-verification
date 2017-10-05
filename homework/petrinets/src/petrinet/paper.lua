local Petrinet = require "petrinet"
local result   = Petrinet.create ()

result.up      = result:place (1)
result.down    = result:place (0)
result.on      = result:place (1)
result.off     = result:place (0)
result.fuel    = result:place (2)
result.filled  = result:place (0)
result.maximum = result:place (2)
result.press  = result:transition {
  result.up   - 1,
  result.down + 1,
}
result.release  = result:transition {
  result.up   + 1,
  result.down - 1,
}
result.start  = result:transition {
  result.off - 1,
  result.on  + 1,
}
result.stop  = result:transition {
  result.off + 1,
  result.on  - 1,
}
result.fill  = result:transition {
  result.down    - 1,
  result.down    + 1,
  result.on      - 1,
  result.on      + 1,
  result.fuel    - 1,
  result.maximum - 1,
  result.filled  + 1,
}
result.empty  = result:transition {
  result.on      - 1,
  result.on      + 1,
  result.maximum + 1,
  result.filled  - 1,
}

return result
