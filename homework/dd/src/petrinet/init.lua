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
  assert (marking == nil or type (marking) == "boolean")
  return setmetatable ({
    marking = marking or false,
  }, Petrinet.Place)
end

function Petrinet.Place.__tostring (place)
  assert (getmetatable (place) == Petrinet.Place)
  return place.id
end

function Petrinet.Place.__unm (place)
  assert (getmetatable (place) == Petrinet.Place)
  return setmetatable ({
    type      = "pre",
    place     = place,
    valuation = true,
  }, Petrinet.Arc)
end

function Petrinet.transition (petrinet, t)
  assert (getmetatable (petrinet) == Petrinet)
  assert (type (t) == "table")
  assert (Fun.frommap (t):all (function (_, arc)
    return getmetatable (arc) == Petrinet.Arc
        or getmetatable (arc) == Petrinet.Place
  end))
  t = Fun.frommap (t):map (function (k, arc)
    if getmetatable (arc) == Petrinet.Place then
      arc = setmetatable ({
        type      = "post",
        place     = arc,
        valuation = true,
      }, Petrinet.Arc)
    end
    return k, arc
  end):tomap ()
  return setmetatable (t, Petrinet.Transition)
end

function Petrinet.places (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  return Fun.frommap (petrinet)
        :filter (function (_, place)
          return getmetatable (place) == Petrinet.Place
        end)
        :map (function (_, place)
          return place
        end)
end

function Petrinet.transitions (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  return Fun.frommap (petrinet)
        :filter (function (_, transition)
          return getmetatable (transition) == Petrinet.Transition
        end)
        :map (function (_, transition)
          return transition
        end)
end

function Petrinet.Transition.pre (transition)
  assert (getmetatable (transition) == Petrinet.Transition)
  return Fun.frommap (transition)
        :filter (function (_, arc)
          return getmetatable (arc) == Petrinet.Arc and arc.type == "pre"
        end)
        :map (function (_, arc)
          return arc
        end)
end

function Petrinet.Transition.post (transition)
  assert (getmetatable (transition) == Petrinet.Transition)
  return Fun.frommap (transition)
        :filter (function (_, arc)
          return getmetatable (arc) == Petrinet.Arc and arc.type == "post"
        end)
        :map (function (_, arc)
          return arc
        end)
end

return Petrinet
