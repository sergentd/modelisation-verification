local Fun  = require "fun"

local Sort      = setmetatable ({}, { __tostring = function () return "Sort"      end })
local Variable  = setmetatable ({}, { __tostring = function () return "Variable"  end })
local Operation = setmetatable ({}, { __tostring = function () return "Operation" end })
local Term      = setmetatable ({}, { __tostring = function () return "Term"      end })
local Rule      = setmetatable ({}, { __tostring = function () return "Rule"      end })
local Strategy  = setmetatable ({}, { __tostring = function () return "Strategy"  end })

local Generator = {}
local Name      = {}
local Rules    = {}

-- ## Sort

Sort.__index = Sort

getmetatable (Sort).__call = function (_, name)
  return setmetatable ({
    [Name  ] = name,
    [Rules] = {},
  }, Sort)
end

function Sort.__tostring (sort)
  return tostring (sort [Name])
end

function Sort.generators (t)
  assert (type (t) == "table",
          "parameter must be a table of generators")
  Fun.fromtable (t)
    : each (function (x)
              assert (getmetatable (x) == Operation,
                      "parameters must be operations")
            end)
  Fun.fromtable (t)
    : each (function (x) x [Generator] = true end)
end

-- ## Variable

Variable.__index = Variable

getmetatable (Variable).__call = function (_, t)
  assert (type (t) == "table")
  local result = setmetatable ({
    [Name] = t [Name],
    [Sort] = t [Sort],
  }, Variable)
  return result
end

function Variable.__tostring (variable)
  return tostring (variable [Name]) .. ": " .. tostring (variable [Sort])
end

-- ## Operation

function Sort.__index (sort, key)
  if rawget (Sort, key)
  or (type (key) == "string" and key:match "^__") then
    return rawget (Sort, key)
  elseif key:match "^_" then
    local result = Variable {
      [Name] = key:match "^_(.*)$",
      [Sort] = sort,
    }
    rawset (sort, key, result)
    return result
  end
end

function Sort.__newindex (sort, key, t)
  if type (t) == "table" then
    Fun.frommap (t):each (function (k, s)
      assert (getmetatable (s) == Sort or s == "function",
              tostring (k) .. " must be a sort or 'function'")
    end)
    local result = setmetatable ({
      [Name] = key,
      [Sort] = sort,
    }, Operation)
    Fun.frommap (t):each (function (k, v)
      result [k] = v
    end)
    rawset (sort, key, result)
  else
    rawset (sort, key, t)
  end
end

function Operation.__eq (lhs, rhs)
  return Fun.frommap (lhs)
         : all (function (k, v) return rhs [k] == v end)
     and Fun.frommap (rhs)
         : all (function (k, v) return lhs [k] == v end)
end

function Operation.__tostring (operation)
  local t = Fun.frommap (operation)
          : filter  (function (k, _   ) return type (k) ~= "table" end)
          : map     (function (k, sort) return tostring (k) .. ": " .. tostring (sort) end)
          : totable ()
  return tostring (operation [Name])
      .. (#t == 0 and "" or " { " .. table.concat (t, ", ") .. " }")
      .. ": "
      .. tostring (operation [Sort])
end

function Operation.__call (operation, t)
  local result = setmetatable ({
    [Operation] = operation,
    [Name     ] = operation [Name],
    [Sort     ] = operation [Sort],
  }, Term)
  Fun.frommap (t):each (function (k, v)
    assert (operation [k],
            tostring (k) .. " must be a field of " .. tostring (operation [Name]))
    if getmetatable (operation [k]) == Sort then
      assert (getmetatable (v) == Term or getmetatable (v) == Variable,
              tostring (k) .. " must be a term or a variable")
    elseif operation [k] == "function" then
      assert (type (v) == "function")
    else
      assert (false)
    end
    if getmetatable (v) == Term then
      assert (v [Sort] == operation [k],
              tostring (k) .. " must be of sort " .. tostring (operation [k]))
    elseif getmetatable (v) == Variable then
      assert (v [Sort] == operation [k],
              tostring (k) .. " must be of sort " .. tostring (operation [k]))
    end
    result [k] = v
  end)
  return result
end

-- ## Term

Term.__index = Term

function Term.__tostring (term)
  local t = Fun.frommap (term)
          : filter  (function (k, _) return type (k) ~= "table" end)
          : map     (function (k, t) return tostring (k) .. " = " .. tostring (t) end)
          : totable ()
  return tostring (term [Name])
      .. (#t == 0 and "" or " { " .. table.concat (t, ", ") .. " }")
      .. ": " .. tostring (term [Sort])
end

function Term.__eq (lhs, rhs)
  if getmetatable (lhs) ~= getmetatable (rhs) then
    return false
  end
  assert (getmetatable (lhs) == Term or getmetatable (lhs) == Variable or type (lhs) == "function",
          "lhs must be a term or a variable or a function")
  assert (getmetatable (rhs) == Term or getmetatable (rhs) == Variable or type (rhs) == "function",
          "rhs must be a term or a variable or a function")
  return Fun.frommap (lhs)
         : all (function (k, v) return rhs [k] == v end)
     and Fun.frommap (rhs)
         : all (function (k, v) return lhs [k] == v end)
end

function Term.equivalence (lhs, rhs)
  assert (getmetatable (lhs) == Term or getmetatable (lhs) == Variable or type (lhs) == "function",
          "lhs must be a term or a variable or a function")
  assert (getmetatable (rhs) == Term or getmetatable (rhs) == Variable or type (rhs) == "function",
          "rhs must be a term or a variable or a function")
  if lhs [Sort] ~= rhs [Sort] then
    return nil
  end
  local variables = {}
  local function compare (l, r)
    local result
    if  getmetatable (l) == Variable
    and getmetatable (r) == Variable then
      if (variables [l] and variables [l] ~= r)
      or (variables [r] and variables [r] ~= l) then
        result = false
      else
        variables [l] = r
        variables [r] = l
        result = true
      end
    elseif getmetatable (l) == Variable
       and getmetatable (r) == Term then
      if variables [l] and variables [l] ~= r then
        result = false
      else
        variables [l] = r
        result = true
      end
    elseif getmetatable (l) == Term
       and getmetatable (r) == Variable then
      if variables [r] and variables [r] ~= l then
        result = false
      else
        variables [r] = l
        result = true
      end
    elseif getmetatable (l) == Term
       and getmetatable (r) == Term then
      if l [Operation] == r [Operation] then
        result = Fun.frommap (l [Operation])
          : filter (function (k) return type (k) ~= "table" end)
          : all (function (k) return compare (l [k], r [k]) end)
      else
        result = false
      end
    elseif type (l) == "function"
       and type (r) == "function" then
      return l == r
    end
    return result
  end
  return compare (lhs, rhs), variables
end

function Term.__div (term, mapping)
  assert (getmetatable (term) == Term or getmetatable (term) == Variable or type (term) == "function",
          "term must be a term or a variable or a function")
  assert (type (mapping) == "table")
  Fun.frommap (mapping):each (function (k, v)
    assert (getmetatable (k) == Variable,
            tostring (k) .. " must be a variable")
    assert (getmetatable (v) == Variable or getmetatable (v) == Term or type (v) == "function",
            tostring (k) .. " must be a term or a variable")
  end)
  local function rename (t)
    if getmetatable (t) == Variable then
      return mapping [t] or t
    elseif getmetatable( t) == Term then
      return t [Operation] (Fun.frommap (t)
        : filter  (function (k, _) return type (k) ~= "table" end)
        : map     (function (k, v) return k, rename (v) end)
        : tomap ())
    elseif type (t) == "function" then
      return t
    end
  end
  return rename (term)
end

Variable.__div = Term.__div

-- ## Rule

getmetatable (Rule).__call = function (_, t)
  assert (type (t) == "table",
          "Rule takes a table as parameter")
  assert (#t == 2,
          "rule must be between two terms")
  local result = setmetatable ({}, Rule)
  Fun.frommap (t):each (function (k, v)
    if type (k) == "number" then
      assert (getmetatable (v) == Term or getmetatable (v) == Variable,
              tostring (k) .. " must be a term or a variable")
    end
    result [k] = v
  end)
  return result
end

function Rule.__tostring (rule)
  local t = Fun.fromtable (rule)
          : map (function (x) return tostring (x) end)
          : totable ()
  return table.concat (t, " = ")
end

function Rule.__eq (lhs, rhs)
  return Fun.frommap (lhs)
         : all (function (k, v) return rhs [k] == v end)
     and Fun.frommap (rhs)
         : all (function (k, v) return lhs [k] == v end)
end

-- ## Strategy

Strategy.__index = Strategy

getmetatable (Strategy).__call = function (_, f)
  assert (type (f) == "function",
          "parameter must be a function of terms")
  return setmetatable ({
    apply = f,
  }, Strategy)
end

function Strategy.__tostring ()
  return "strategy"
end

function Strategy.__call (strategy, term)
  assert (getmetatable (strategy) == Strategy,
          "strategy must be a strategy")
  assert (term == nil
        or type (term) == "function"
        or getmetatable (term) == Term
        or getmetatable (term) == Variable,
          "term must be a term or a variable")
  if term == nil then
    return nil
  elseif type (term) == "function" then
    return term
  else
    return strategy.apply (term)
  end
end

Strategy.fail = Strategy (function ()
  return nil
end)

Strategy.identity = Strategy (function (term)
  return term
end)

function Strategy.rule (rule)
  assert (getmetatable (rule) == Rule,
          "parameter must be a rule")
  return Strategy (function (term)
    local ok, mapping = Term.equivalence (term, rule [1])
    if ok then
      return rule [2] / mapping
    else
      return nil
    end
  end)
end

function Strategy.sequence (t)
  assert (type (t) == "table")
  Fun.fromtable (t):each (function (x)
    assert (getmetatable (x) == Strategy,
            "parameters must be strategies")
  end)
  return Strategy (function (term)
    return Fun.fromtable (t):reduce (function (r, s)
      return s (r)
    end, term)
  end)
end

function Strategy.choice (t)
  assert (type (t) == "table")
  Fun.fromtable (t):each (function (x)
    assert (getmetatable (x) == Strategy,
            "parameters must be strategies")
  end)
  return Strategy (function (term)
    return Fun.fromtable (t):reduce (function (r, s)
      if r == nil then
        return s (term)
      else
        return r
      end
    end)
  end)
end

function Strategy.all (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy (function (term)
    return term [Operation] (Fun.frommap (term)
      : filter  (function (k, _) return type (k) ~= "table" end)
      : map     (function (k, v) return k, s (v) end)
      : tomap ())
  end)
end

function Strategy.one (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  -- TODO
  return Strategy (function (term)
    local l = 1
    local t
    repeat
      t = s(term[1])
      l = l + 1
    until (l > #s or t ~=nil)
    if t == nil then
      return Strategy.fail ()
    end
    term [l-1] = t
    return term
  end)
end

function Strategy.try (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy.choice { s, Strategy.identity }
end

function Strategy.recursive (f)
  assert (type (f) == "function",
          "parameter must be a function")
  local t = {}
  local s = Strategy (function (term)
    return t.strategy (term)
  end)
  t.strategy = f (s)
  return t.strategy
end

function Strategy.fixpoint (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy.recursive (function (r)
    return Strategy.choice { Strategy.sequence { s, r }, Strategy.identity }
  end)
end

function Strategy.bottomup (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy.recursive (function (r)
    return Strategy.sequence { Strategy.all (r), s }
  end)
end

function Strategy.topdown (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy.recursive (function (r)
    return Strategy.sequence { s, Strategy.all (r) }
  end)
end

function Strategy.innermost (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  return Strategy.recursive (function (r)
    return Strategy.sequence { Strategy.all (r), Strategy.try (Strategy.sequence { s, r }) }
  end)
end

function Strategy.outermost (s)
  assert (getmetatable (s) == Strategy,
          "parameter must be a strategy")
  -- TODO
  return Strategy.recursive (function (r)
    return Strategy.sequence { Strategy.try (Strategy.sequence { s, r }), Strategy.all (r) }
  end)
end

-- # Adt

return {
  name      = Name,
  generator = Generator,
  rules     = Rules,
  Sort      = Sort,
  Variable  = Variable,
  Operation = Operation,
  Term      = Term,
  Rule      = Rule,
  Strategy  = Strategy,
  rule      = function (...) return Rule (...) end,
}
