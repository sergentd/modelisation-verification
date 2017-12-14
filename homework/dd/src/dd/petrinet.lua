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

  local transitions = -- TODO

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
