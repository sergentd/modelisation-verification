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

-- Increment
Natural [Adt.axioms].increment = Adt.axiom {
  Natural.Increment { Natural._v },
  Natural.Successor { Natural._v },
}

-- Decrement
Natural [Adt.axioms].decrement = Adt.axiom {
  Natural.Decrement { Natural.Successor { Natural._v } },
  Natural._v,
}

-- Addition
Natural [Adt.axioms].x_addition_y = Adt.axiom {
  Natural.Addition { Natural._x, Natural._y },
  Natural.Addition { Natural._y, Natural._x },
}

Natural [Adt.axioms].x_addition_zero = Adt.axiom {
  Natural.Addition { Natural._x, Natural.Zero {} },
  Natural._x,
}

Natural [Adt.axioms].x_addition_sy = Adt.axiom {
  Natural.Addition  { Natural._x, Natural.Successor { Natural._y } },
  Natural.Successor { Natural.Addition { Natural._x, Natural._y } },
}

-- Substraction
Natural [Adt.axioms].v_substraction_zero = Adt.axiom {
  Natural.Subtraction { Natural._v, Natural.Zero {} },
  Natural._v,
}

Natural [Adt.axioms].sx_substraction_sy = Adt.axiom {
  Natural.Subtraction { Natural.Successor { Natural._x },
                        Natural.Successor { Natural._y } },
  Natural.Subtraction { Natural._x, Natural._y },
}

-- Is_even
Natural [Adt.axioms].is_even_zero = Adt.axiom {
  Boolean.Is_even { Natural.Zero {} },
  Boolean.True {},
}

Natural [Adt.axioms].is_even_sv = Adt.axiom {
  Boolean.Is_even { Natural.Successor { Natural._v } },
  Boolean.Not { Boolean.Is_even { Natural._v } },
}

return Natural
