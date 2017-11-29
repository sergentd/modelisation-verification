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
  Natural.Successor { Natural._v }
}
Natural [Adt.rules].addition_zero = Adt.rule {
  Natural.Addition { Natural._x, Natural.Zero {} },
  Natural._x
}
Natural [Adt.rules].addition_nonzero = Adt.rule {
  Natural.Addition  { Natural._x, Natural.Successor { Natural._y } },
  Natural.Successor { Natural.Addition { Natural._x, Natural._y} }
}

-- TODO: define rules for other operations

-- Decrement
Natural [Adt.axioms].decrement = Adt.axiom {
  Natural.Decrement { Natural.Successor { Natural._v } },
  Natural._v,
}

-- Substraction
Natural [Adt.axioms].subtraction_zero = Adt.axiom {
  Natural.Subtraction { Natural._x, Natural.Zero {} },
  Natural._x
}
Natural [Adt.axioms].subtraction_nonzero = Adt.axiom {
  Natural.Subtraction { Natural._x, Natural.Decrement { Natural._y } },
  Natural.Decrement { Natural.Subtraction { Natural._x, Natural._y } }
}
Natural [Adt.axioms].sx_substraction_sy = Adt.axiom {
  Natural.Subtraction { Natural.Successor { Natural._x },
                        Natural.Successor { Natural._y } },
  Natural.Subtraction { Natural._x, Natural._y }
}

-- Is_even
Boolean [Adt.axioms].is_even_zero = Adt.axiom {
  Boolean.Is_even { Natural.Zero {} },
  Boolean.True {}
}
Boolean [Adt.axioms].is_even_nonzero = Adt.axiom {
  Boolean.Is_even { Natural._x },
  Boolean.Not { Boolean.Is_even { Natural.Decrement { Natural._x } } }
}
Natural [Adt.axioms].is_even_sx = Adt.axiom {
  Boolean.Is_even { Natural.Successor { Natural._x } },
  Boolean.Not { Boolean.Is_even { Natural._x } }
}

return Natural
