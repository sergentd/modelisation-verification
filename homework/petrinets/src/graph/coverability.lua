local Fun     = require "fun"
local Graph   = require "graph"
local Marking = require "marking"

local Coverability = {}

function Coverability.create (t)
  t = t or {
    traversal = Graph.depth_first,
  }
  assert (type (t) == "table")
  assert (type (t.traversal) == "function")
  return Graph.create {
    traversal = t.traversal,
    omegize   = function (x)
      -- TODO: replace marking by omega if needed
      -- look at graph/init.lua to understand what data are given in `x`
    end,
  }
end

return Coverability
