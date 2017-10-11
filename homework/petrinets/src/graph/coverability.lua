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
    omegize   = function (x) -- TODO
        if x.parent.marking <= x.current.marking then
          Fun.each (function(place)
            if (type (x.current.marking[place]) == "number"
                and   x.current.marking[place]  >  x.parent.marking[place])
            or (type (x.current.marking[place]) ~= "number"
                and   x.current.marking[place]  ~= Marking.omega)
            then
              x.current.marking[place] = Marking.omega
            end
          end, x.current.petrinet:places ())
        end
    end
  }
end

return Coverability
