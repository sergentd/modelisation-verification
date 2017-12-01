local Fun      = require "fun"
local Petrinet = require "petrinet"
local Marking  = require "marking"

local State = {}
State.__index = State

function State.create (petrinet)
  assert (getmetatable (petrinet) == Petrinet)
  local result = setmetatable ({
    petrinet   = petrinet,
    marking    = Marking.initial (petrinet),
    successors = {},
    properties = {},
  }, State)
  return result
end

function State.__call (state, transition)
  assert (getmetatable (state) == State)
  assert (getmetatable (transition) == Petrinet.Transition)
  if not Fun.all (function (pre)
    return Marking.create {
      [pre.place] = state.marking [pre.place],
    } >= Marking.create {
      [pre.place] = pre.valuation,
    }
  end, transition:pre ()) then
    return nil, "transition is not enabled"
  end
  local pre  = Marking.create (Fun.tomap (Fun.map (function (arc)
    return arc.place, arc.valuation
  end, transition:pre ())))
  local post = Marking.create (Fun.tomap (Fun.map (function (arc)
    return arc.place, arc.valuation
  end, transition:post ())))
  return setmetatable ({
    petrinet   = state.petrinet,
    marking    = state.marking - pre + post,
    successors = {},
    properties = {},
  }, State)
end

function State.enabled (state)
  assert (getmetatable (state) == State)
  return Fun.filter (function (transition)
    return Fun.all (function (pre)
      return Marking.create {
        [pre.place] = state.marking [pre.place],
      } >= Marking.create {
        [pre.place] = pre.valuation,
      }
    end, transition:pre ())
  end, state.petrinet:transitions ())
end

local function sort (lhs, rhs)
  if type (lhs) == type (rhs) then
    return lhs < rhs
  else
    return type (lhs) < type (rhs)
  end
end

local function goes_to (current, final, path)
  if current == final then
    return true
  elseif path [current] then
    return false
  end
  local result   = false
  path [current] = true
  for _, child in pairs (current.successors) do
    result = result or goes_to (child, final, path)
  end
  path [current] = nil
  return result
end

function State.__le (lhs, rhs)
  return goes_to (lhs, rhs, {})
end

function State.__lt (lhs, rhs)
  return lhs ~= rhs and goes_to (lhs, rhs, {})
end

function State.__tostring (state)
  assert (getmetatable (state) == State)
  local places = {}
  local names  = Fun.totable (Fun.map (function (place, marking)
    for k, v in pairs (state.petrinet) do
      if v == place then
        places [k] = marking
        return k
      end
    end
  end, Fun.frommap (state.marking)))
  table.sort (names, sort)
  return table.concat (Fun.totable (Fun.map (function (name)
    return tostring (name) .. "=" .. tostring (places [name])
  end, names)), ",")
end

return State
