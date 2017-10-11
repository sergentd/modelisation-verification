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
    omegize   = function (state)
        if state.current <= state.parent then
          print('ok')
        end
        --print(state.current, state.initial, state.parent, state.states)
    end,
  }
end

return Coverability
