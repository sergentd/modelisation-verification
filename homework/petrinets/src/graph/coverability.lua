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
        if state.current.marking >= state.parent.marking then
          Fun.each(function(place)
            if (type (state.current.marking[place]) == "number"
           and state.current.marking[place] >  state.parent.marking[place])
            or state.current.marking[place] == Marking.omega then
               state.current.marking[place] =  Marking.omega
           end
        end, state.current.petrinet:places ())
      end
    end,
  }
end

return Coverability
