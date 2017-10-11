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
  assert (getmetatable (state)      == State)
  assert (getmetatable (transition) == Petrinet.Transition)
  local transitions = Fun.tomap (state:enabled ())
  if transitions[transition] == nil then
    return nil, "transition not enabled"
  end
  local pre  = {}
  for _,arc in transition:pre () do pre[arc.place] = arc.valuation end
  local post = {}
  for _,arc in transition:post () do post[arc.place] = arc.valuation end
  return setmetatable ({
    petrinet   = state.petrinet,
    marking    = state.marking - pre + post,
    successors = {},
  }, State)
end

function State.enabled (state)
  assert (getmetatable (state) == State)
  local transitions = {}
  for _,transition in state.petrinet:transitions () do
    assert (getmetatable (transition) == Petrinet.Transition)
    local enabled = Fun.all (function (arc)
      return assert (getmetatable (arc) == Petrinet.Arc)
         and assert (type (arc.valuation) == "number" and arc.valuation >= 0)
         and assert (type (arc.place.marking) == "number" and arc.place.marking >= 0)
         and state.marking[arc.place] >= arc.valuation
    end,   transition:pre ())
    if enabled then
      transitions[transition] = transition
    end
  end
  return Fun.iter (transitions)
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
