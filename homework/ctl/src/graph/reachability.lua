local Graph = require "graph"

local Reachability = {}

function Reachability.create (t)
  t = t or {
    traversal = Graph.depth_first,
  }
  assert (type (t) == "table")
  assert (type (t.traversal) == "function")
  return Graph.create {
    traversal = t.traversal,
    omegize   = function () end,
  }
end

return Reachability
