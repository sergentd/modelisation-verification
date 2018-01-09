local Fun = require "fun"

return function (variables)

  local Node     = {}
  local Terminal = {}
  local nodes    = { false }

  local Dd    = {
    Node     = Node,
    Terminal = Terminal,
    nodes    = nodes,
  }

  local function terminal (value)
    assert (type (value) == "boolean")
    return Dd.unique (setmetatable ({
      value = value,
    }, Terminal))
  end

  function Terminal.__tostring (dd)
    return (dd.id and "@" .. tostring (dd.id) .. "." or "")
        .. "[" .. tostring (dd.value) .. "]"
  end

  local function node (t)
    assert (t.variable and Fun.fromtable (variables):index (t.variable),
            "t.variable must be a variable")
    assert (getmetatable (t [true]) == Terminal or getmetatable (t [true]) == Node,
            "t [true] must be a terminal or a node")
    assert (getmetatable (t [false]) == Terminal or getmetatable (t [false]) == Node,
            "t [false] must be a terminal or a node")
    return Dd.unique (setmetatable ({
      variable = t.variable,
      [true ]  = t [true],
      [false]  = t [false],
    }, Node))
  end

  function Node.__tostring (dd)
    local sub = {}
    Fun.frommap (dd):each (function (k, v)
      if k ~= "id" and k ~= "variable" then
        sub [#sub+1] = tostring (k) .. "=" .. (v.id and "@" .. tostring (v.id) or tostring (v))
      end
    end)
    return (dd.id and "@" .. tostring (dd.id) .. "=" or "")
        .. tostring (dd.variable) .. ":{"
        .. tostring (true) .. "=" .. (dd [true].id and "@" .. tostring (dd [true].id) or tostring (dd [true]))
        .. ","
        .. tostring (false) .. "=" .. (dd [false].id and "@" .. tostring (dd [false].id) or tostring (dd [false]))
        .. "}"
  end

  function Dd.paths (dd)
    local function f (x)
      if getmetatable (x) == Terminal then
        if x.value then
          return { { terminal = x.value } }
        else
          return {}
        end
      elseif getmetatable (x) == Node then
        local r = {}
        local _true  = f (x [true ])
        for _, t in ipairs (_true) do
          t [x.variable] = true
          r [#r+1] = t
        end
        local _false = f (x [false])
        for _, t in ipairs (_false) do
          t [x.variable] = false
          r [#r+1] = t
        end
        return r
      else
        assert (false)
      end
    end
    return f (dd)
  end

  function Dd.show (dd)
    local result = getmetatable (dd) == Terminal
                or getmetatable (dd) == Node
               and Dd.paths (dd)
                or dd
    if #result > 0 then
      result = Fun.fromtable (result):map (function (t)
        local r = {}
        for i = 1, #variables do
          local variable = variables [i]
          local value    = t [variable]
          r [i] = tostring (variable) .. "=" .. tostring (value == nil and "*" or value)
        end
        r [#variables+1] = "-> " .. tostring (t.terminal)
        return table.concat (r, " ")
      end):totable ()
      print (table.concat (result, "\n"))
    end
  end

  function Dd.dontcare (dd)
    -- TODO: return the `dd` with don't care applied
    if getmetatable (dd) == Terminal then
      return dd
    elseif getmetatable (dd) == Node then
      if dd[true] == dd[false] then
        return dd[true]
      else
        return dd
      end
    else
      assert (false)
    end
  end

  function Dd.unique (dd)
    if dd.id then
      return dd
    end
    if getmetatable (dd) == Node then
      dd [true ] = Dd.unique (Dd.dontcare (dd [true ]))
      dd [false] = Dd.unique (Dd.dontcare (dd [false]))
    end
    dd = Dd.dontcare (dd)
    local id = Fun.fromtable (nodes):index (dd)
    if not id then
      id = #nodes+1
      dd.id = id
      nodes [id] = dd
    end
    return nodes [id]
  end

  local function eq (lhs, rhs)
    if lhs.id and rhs.id then
      return lhs.id == rhs.id
    end
    if getmetatable (lhs) == getmetatable (rhs) then
      if getmetatable (lhs) == Terminal then
        return lhs.value == rhs.value
      elseif getmetatable (lhs) == Node then
        return lhs.variable == rhs.variable
           and lhs [true ]  == rhs [true ]
           and lhs [false]  == rhs [false]
      end
    else
      return false
    end
  end
  Terminal.__eq = eq
  Node    .__eq = eq

  local function add (lhs, rhs)
    local vars = Fun.fromtable (variables)
    if getmetatable (lhs) == Terminal and getmetatable (rhs) == Terminal then
      return terminal (lhs.value or rhs.value)
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Node
       and lhs.variable == rhs.variable then
      return node {
        variable = lhs.variable,
        [true ]  = lhs [true ] + rhs [true ],
        [false]  = lhs [false] + rhs [false],
      }
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Terminal
        or getmetatable (lhs) == Node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) < vars:index (rhs.variable) then
      return node {
        variable = lhs.variable,
        [true ]  = lhs [true ] + rhs,
        [false]  = lhs [false] + rhs,
      }
    elseif getmetatable (lhs) == Terminal and getmetatable (rhs) == Node
        or getmetatable (lhs) == Node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) > vars:index (rhs.variable) then
      return node {
        variable = rhs.variable,
        [true ]  = lhs + rhs [true ],
        [false]  = lhs + rhs [false],
      }
    end
  end
  Terminal.__add = add
  Node    .__add = add

  local function mul (lhs, rhs)
    -- TODO
    local vars = Fun.fromtable (variables)
    if getmetatable (lhs) == Terminal and getmetatable (rhs) == Terminal then
      return terminal (lhs.value and rhs.value)
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Node
       and lhs.variable == rhs.variable then
      return node {
        variable = rhs.variable,
        [true ]  = lhs [true ] * rhs [true ],
        [false]  = lhs [false] * rhs [false],
      }
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Terminal
        or getmetatable (lhs) == node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) < vars:index (rhs.variable) then
      return node {
        variable = lhs.variable,
        [true ]  = lhs[true ] * rhs,
        [false]  = lhs[false] * rhs,
      }
    elseif getmetatable (lhs) == Terminal and getmetatable (rhs) == Node
        or getmetatable (lhs) == node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) > vars:index (rhs.variable) then
      return node {
        variable = rhs.variable,
        [true ]  = lhs * rhs [true ],
        [false]  = lhs * rhs [false],
      }
    end
  end
  Terminal.__mul = mul
  Node    .__mul = mul

  local function sub (lhs, rhs)
    -- TODO
    local vars = Fun.fromtable (variables)
    if getmetatable (lhs) == Terminal and getmetatable (rhs) == Terminal then
      return terminal (lhs.value and not rhs.value)
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Node
       and lhs.variable == rhs.variable then
      return node {
        variable = rhs.variable,
        [true ]  = lhs + rhs [true ],
        [false]  = lhs + rhs [false],
      }
    elseif getmetatable (lhs) == Node and getmetatable (rhs) == Terminal
        or getmetatable (lhs) == node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) < vars:index (rhs.variable) then
      return node {
        variable = lhs.variable,
        [true ]  = lhs[true ] - rhs,
        [false]  = lhs[false] - rhs,
      }
    elseif getmetatable (lhs) == Terminal and getmetatable (rhs) == Node
        or getmetatable (lhs) == node and getmetatable (rhs) == Node
       and vars:index (lhs.variable) > vars:index (rhs.variable) then
      return node {
        variable = rhs.variable,
        [true ]  = lhs - rhs [true ],
        [false]  = lhs - rhs [false],
      }
    end
  end
  Terminal.__sub = sub
  Node    .__sub = sub

  local function create (t)
    local result = terminal (true)
    for i = #variables, 1, -1 do
      local v = variables [i]
      result = node {
        variable    = v,
        [t [v]]     = result,
        [not t [v]] = terminal (false),
      }
    end
    return result
  end

  Dd.terminal = terminal
  Dd.node     = node
  Dd.create   = create

  local Constant = {}

  function Dd.constant (x)
    return setmetatable ({ x = x}, Constant)
  end

  function Constant.__call (constant, _)
    return constant.x
  end

  local Identity = {}

  function Dd.identity ()
    return setmetatable ({}, Identity)
  end

  function Identity.__call (_, dd)
    return dd
  end

  local Filter = {}

  function Dd.filter (f)
    return setmetatable ({ f = f }, Filter)
  end

  function Filter.compute (filter, i, data)
    if i > #variables then
      if filter.f (data) then
        return terminal (true)
      else
        return terminal (false)
      end
    else
      local v = variables [i]
      if data [v] == nil then
        local _true  = Fun.frommap (data):tomap ()
        _true  [v] = true
        local _false = Fun.frommap (data):tomap ()
        _false [v] = false
        return Filter.compute (filter, i+1, _true )
             + Filter.compute (filter, i+1, _false)
      else
        return Filter.compute (filter, i+1, data)
      end
    end
  end

  function Filter.__call (filter, dd, data)
    -- TODO
    data = data or {}
    if getmetatable (dd) == Terminal then
      if dd.value then
        return Filter.compute (filter, 1, data)
      else
        return terminal (false)
      end
    elseif getmetatable (dd) == Node then
      local _true  = Fun.frommap (data):tomap ()
      _true  [dd.variable] = true
      local _false = Fun.frommap (data):tomap ()
      _false [dd.variable] = false
      return node {
        variable = dd.variable,
        [true ] = filter (dd [true ], _true ),
        [false] = filter (dd [false], _false),
      }
    else
      assert (false)
    end
  end

  local Map = {}

  function Dd.map (f)
    return setmetatable ({ f = f }, Map)
  end

  function Map.compute (map, dd)
    -- TODO
    return map, dd
  end

  function Map.__call (map, dd)
    -- TODO
    if getmetatable (dd) == Terminal then
      if dd.value then
        return Map.compute (map, dd)
      else
        return terminal (false)
      end
    elseif getmetatable (dd) == Node then
      return map
    else
      assert (false)
    end
  end

  local Composition  = {}

  function Dd.composition (t)
    return setmetatable (Fun.fromtable (t):totable (), Composition)
  end

  function Composition.__call (composition, dd)
    return Fun.fromtable (composition):reduce (function (r, x)
      return x (r)
    end, dd)
  end

  local Union = {}

  function Dd.union (t)
    return setmetatable (Fun.fromtable (t):totable (), Union)
  end

  function Union.__call (union, dd)
    return Fun.fromtable (union):reduce (function (r, x)
      return r + x (dd)
    end, terminal (false))
  end

  local Intersection = {}

  function Dd.intersection (t)
    return setmetatable (Fun.fromtable (t):totable (), Intersection)
  end

  function Intersection.__call (intersection, dd)
    return Fun.fromtable (intersection):reduce (function (r, x)
      return r * x (dd)
    end, terminal (true))
  end

  local Difference   = {}

  function Dd.difference (t)
    return setmetatable (Fun.fromtable (t):totable (), Difference)
  end

  function Difference.__call (difference, dd)
    return Fun.fromtable (difference):drop (1):reduce (function (r, x)
      return r - x (dd)
    end, difference [1] (dd))
  end

  local Fixpoint = {}

  function Dd.fixpoint (o)
    return setmetatable ({ o = o }, Fixpoint)
  end

  function Fixpoint.__call (fixpoint, dd)
    repeat
      local back = dd
      dd = fixpoint.o (dd)
    until dd == back
    return dd
  end

  local function compose (lhs, rhs)
    return Dd.composition { lhs, rhs }
  end
  Identity    .__concat = compose
  Filter      .__concat = compose
  Map         .__concat = compose
  Composition .__concat = compose
  Union       .__concat = compose
  Intersection.__concat = compose
  Difference  .__concat = compose
  Fixpoint    .__concat = compose

  local function union (lhs, rhs)
    return Dd.union { lhs, rhs }
  end
  Identity    .__add = union
  Filter      .__add = union
  Map         .__add = union
  Composition .__add = union
  Union       .__add = union
  Intersection.__add = union
  Difference  .__add = union
  Fixpoint    .__add = union

  local function intersection (lhs, rhs)
    return Dd.intersection { lhs, rhs }
  end
  Identity    .__mul = intersection
  Filter      .__mul = intersection
  Map         .__mul = intersection
  Composition .__mul = intersection
  Union       .__mul = intersection
  Intersection.__mul = intersection
  Difference  .__mul = intersection
  Fixpoint    .__mul = intersection

  local function difference (lhs, rhs)
    return Dd.difference { lhs, rhs }
  end
  Identity    .__sub = difference
  Filter      .__sub = difference
  Map         .__sub = difference
  Composition .__sub = difference
  Union       .__sub = difference
  Intersection.__sub = difference
  Difference  .__sub = difference
  Fixpoint    .__sub = difference

  return Dd
end
