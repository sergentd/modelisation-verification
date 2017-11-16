local Fun     = require "fun"
local Adt     = require "adt"
local Boolean = require "adt.boolean"
local Natural = Adt.Sort "Natural"

Natural.Zero        = {}
Natural.Successor   = { Natural }
Natural.Increment   = { Natural }
Natural.Decrement   = { Natural }
Natural.Addition    = { Natural, Natural }
Natural.Subtraction = { Natural, Natural }
Boolean.Is_even     = { Natural }

Natural.generators { Natural.Zero, Natural.Successor }

function Natural.nth (n)
  return Fun.range (1, n)
       : reduce (function (i) return Natural.Successor { i } end, Natural.Zero {})
end

Natural [Adt.rules].increment = Adt.rule {
  Natural.Increment { Natural._v },
  Natural.Successor { Natural._v },
}
Natural [Adt.rules].addition_zero = Adt.rule {
  Natural.Addition { Natural._x, Natural.Zero {} },
  Natural._x,
}
Natural [Adt.rules].addition_nonzero = Adt.rule {
  Natural.Addition  { Natural._x, Natural.Successor { Natural._y } },
  Natural.Successor { Natural.Addition { Natural._x, Natural._y} },
}

-- TODO: define rules for other operations

return Natural
