local Fun      = require "fun"
local Petrinet = require "petrinet"

return function (petrinet)

  local variables = Fun.frommap (petrinet):filter (function (_, v)
    return getmetatable (v) == Petrinet.Place
  end):map (function (k, place)
    place.id = k
    return place
  end):totable ()

  local Dd = require "dd" (variables)

 -- TODO
  local transitions = Fun.frommap (petrinet):filter (function (_, v)
    return getmetatable (v) == Petrinet.Transition
  end):map (function (_, transition)
      local pre  = transition:pre  ()
      local post = transition:post ()
      return Dd.filter (function (state)
        return pre:all (function (arc)
          return arc.valuation and state [arc.place]
        end)
      end) .. Dd.map (function (state)
      pre :each (function (arc)
        state [arc.place] = false
      end)
      post:each (function (arc)
        state [arc.place] = true
      end)
    return state
    end)
  end):totable ()

  local initial = Dd.create (Fun.frommap (petrinet):filter (function (_, v)
    return getmetatable (v) == Petrinet.Place
  end):map (function (_, place)
    return place, place.marking
  end):tomap ())

  return setmetatable ({
    variables = variables,
    initial   = initial,
    generate  = Dd.fixpoint (Dd.identity () + Dd.union (transitions)),
  }, { __index = Dd })
end
