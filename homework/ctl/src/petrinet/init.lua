local Fun = require "fun"

local Petrinet = {}

Petrinet.Place      = {}
Petrinet.Transition = {}
Petrinet.Arc        = {}

Petrinet           .__index = Petrinet
Petrinet.Place     .__index = Petrinet.Place
Petrinet.Transition.__index = Petrinet.Transition
Petrinet.Arc       .__index = Petrinet.Arc

function Petrinet.create ()
  return setmetatable ({}, Petrinet)
end

function Petrinet.place (petrinet, marking)
  assert (getmetatable (petrinet) == Petrinet)
  assert (marking == nil or (type (marking) == "number" and marking >= 0))
  return setmetatable ({
    marking = marking or 0,
  }, Petrinet.Place)
end

function Petrinet.Place.__sub (place, valuation)
  assert (getmetatable (place) == Petrinet.Place)
  assert (type (valuation) == "number")
  assert (valuation > 0)
  return setmetatable ({
    type      = "pre",
    place     = place,
    valuation = valuation,
  }, Petrinet.Arc)
end

function Petrinet.Place.__add (place, valuation)
  assert (getmetatable (place) == Petrinet.Place)
  assert (type (valuation) == "number")
  assert (valuation > 0)
  return setmetatable ({
    type      = "post",
    place     = place,
    valuation = valuation,
  }, Petrinet.Arc)
end

function Petrinet.transition (petrinet, t)
  assert (getmetatable (petrinet) == Petrinet)
  assert (type (t) == "table")
  assert (Fun.all (function (_, arc)
    return getmetatable (arc) == Petrinet.Arc
  end, Fun.frommap (t)))
  return setmetatable (Fun.tomap (Fun.frommap (t)), Petrinet.Transition)
end

function Petrinet.places (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  return Fun.map (function (_, place)
    return place
  end, Fun.filter (function (_, place)
    return getmetatable (place) == Petrinet.Place
  end, Fun.frommap (petrinet)))
end

function Petrinet.transitions (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  return Fun.map (function (_, transition)
    return transition
  end, Fun.filter (function (_, transition)
    return getmetatable (transition) == Petrinet.Transition
  end, Fun.frommap (petrinet)))
end

function Petrinet.Transition.pre (transition)
  assert (getmetatable (transition) == Petrinet.Transition)
  return Fun.map (function (_, arc)
    return arc
  end, Fun.filter (function (_, arc)
    return getmetatable (arc) == Petrinet.Arc and arc.type == "pre"
  end, Fun.frommap (transition)))
end

function Petrinet.Transition.post (transition)
  assert (getmetatable (transition) == Petrinet.Transition)
  return Fun.map (function (_, arc)
    return arc
  end, Fun.filter (function (_, arc)
    return getmetatable (arc) == Petrinet.Arc and arc.type == "post"
  end, Fun.frommap (transition)))
end

return Petrinet
