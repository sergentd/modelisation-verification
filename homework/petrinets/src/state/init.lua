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
  }, State)
  return result
end

function State.__call (state, transition)
  assert (getmetatable (state) == State)
  assert (getmetatable (transition) == Petrinet.Transition)
  --if (true) then -- TODO: transition is not fireable
    --return nil, "transition is not enabled"
  --end
  local pre  = {}
  for k, v in pairs(transition:post()) do
    table.insert(pre,{k, v})
  end
  local post = Fun.map (function (_,arc) return arc.place, arc.valuation end, transition:post())
  return setmetatable ({
    petrinet   = state.petrinet,
    marking    = state.marking - pre + post,
    successors = {},
  }, State)
end

function State.enabled (state)
  assert (getmetatable (state) == State)
  local transitions = state.petrinet:transitions ()
  for k, v in pairs (transitions) do
    print (k, v, transitions[k])
  end

  return Fun.map (function (_, transition)
    return transition
  end, Fun.filter (function (_, arc)
    return (getmetatable (arc) == Petrinet.Arc and (arc.valuation <= arc.place.marking))
  end, state.petrinet:transitions ()))
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
