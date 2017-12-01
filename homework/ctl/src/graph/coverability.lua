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
      Fun.each (function (state)
        local difference = x.current.marking - state.marking
        for place, valuation in pairs (difference) do
          if valuation ~= 0 then
            difference [place] = Marking.omega
          end
        end
        x.current.marking = x.current.marking + difference
      end, Fun.filter (function (state)
        return state.marking < x.current.marking
           and state <= x.parent
      end, x.states))
    end,
  }
end

return Coverability
