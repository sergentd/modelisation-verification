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
  local fireable = false
  for k in pairs(state:enabled()) do
    if k == transition then
      --print (k, transition)
      fireable = true
    end
  end
  for k, arc in pairs(transition) do
    print(state, arc.type, arc.place.marking, arc.valuation)
  end
  print('YOLOOOO')
  if (not fireable) then
    print('Perdu')
    return nil, "transition is not enabled"
  end
  local pre  = {}
  for _,arc in transition:pre() do
    pre[arc.place] = arc.valuation
  end
  local post = {}
  for _,arc in transition:post() do
    post[arc.place] = arc.valuation
  end
  return setmetatable ({
    petrinet   = state.petrinet,
    marking    = state.marking - pre + post,
    successors = {},
  }, State)
end

function State.enabled (state)
  assert (getmetatable (state) == State)
  local transitions = {}
  for key,value in state.petrinet:transitions() do
    local enabled = true
    for _,arc in pairs(value) do
      if (arc.type == "pre" and (arc.place.marking < arc.valuation)) then
        enabled = false
      end
    end
    if enabled then
      transitions[value] = enabled
    end
  end
  return transitions
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
