local Fun      = require "fun"
local Petrinet = require "petrinet"
local Marking  = {}

Marking.omega  = setmetatable ({}, {
  __tostring = function () return "ω" end,
})

function Marking.initial (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  return setmetatable (Fun.tomap (Fun.map (function (place)
    return place, place.marking
  end, petrinet:places ())), Marking)
end

function Marking.create (t)
  assert (type (t) == "table")
  assert (Fun.all (function (place, valuation)
    return getmetatable (place) == Petrinet.Place
       and (type (valuation) == "number" and valuation >= 0)
        or valuation == Marking.omega
  end, Fun.frommap (t)))
  return setmetatable (Fun.tomap (Fun.frommap (t)), Marking)
end

function Marking.__eq (lhs, rhs)
  assert (getmetatable (lhs) == Marking)
  assert (getmetatable (rhs) == Marking)
  return Fun.all (function (place, valuation)
       return rhs [place] == valuation
     end, Fun.frommap (lhs))
     and Fun.all (function (place, valuation)
       return lhs [place] == valuation
     end, Fun.frommap (rhs))
end

function Marking.__le (lhs, rhs)
  assert (getmetatable (lhs) == Marking)
  assert (getmetatable (rhs) == Marking)
  return Fun.all (function (place, valuation)
    local r = rhs [place]
    if not r then
      return false
    elseif r == Marking.omega   and valuation == Marking.omega   then
      return true
    elseif r == Marking.omega   and type (valuation) == "number" then
      return true
    elseif type (r) == "number" and type (valuation) == "number" then
      return valuation <= r
    elseif type (r) == "number" and valuation == Marking.omega   then
      return false
    end
  end, lhs)
end

function Marking.__lt (lhs, rhs)
  assert (getmetatable (lhs) == Marking)
  assert (getmetatable (rhs) == Marking)
  return lhs ~= rhs
     and lhs <= rhs
end

function Marking.__add (lhs, rhs)
  local data = {}
  for k, v in pairs (lhs) do
    data [k] = v
  end
  for k, v in pairs (rhs) do
    if data [k] == Marking.omega
    or v        == Marking.omega then
      data [k] = Marking.omega
    else
      data [k] = (data [k] or 0) + v
    end
  end
  return Marking.create (data)
end

function Marking.__sub (lhs, rhs)
  local data = {}
  for k, v in pairs (lhs) do
    data [k] = v
  end
  for k, v in pairs (rhs) do
    if data [k] == Marking.omega
    or v        == Marking.omega then
      data [k] = Marking.omega
    else
      data [k] = (data [k] or 0) - v
    end
  end
  return Marking.create (data)
end

return Marking
