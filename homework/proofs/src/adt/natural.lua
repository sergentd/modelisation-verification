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

Natural [Adt.axioms].increment = Adt.axiom {
  Natural.Increment { Natural._v },
  Natural.Successor { Natural._v },
}
Natural [Adt.axioms].decrement_zero = Adt.axiom {
  Natural.Decrement { Natural.Zero {} },
  Natural.Zero {}
}
Natural [Adt.axioms].decrement_nonzero = Adt.axiom {
  Natural.Decrement { Natural.Successor{ Natural._x } },
  Natural._x
}
Natural [Adt.axioms].addition_zero = Adt.axiom {
  Natural.Addition { Natural._x, Natural.Zero {} },
  Natural._x,
}
Natural [Adt.axioms].addition_nonzero = Adt.axiom {
  Natural.Addition  { Natural._x, Natural.Successor { Natural._y } },
  Natural.Successor { Natural.Addition { Natural._x, Natural._y} },
}
Natural [Adt.axioms].subtraction_zero = Adt.axiom {
  Natural.Subtraction { Natural._x, Natural.Zero {} },
  Natural._x
}
Natural [Adt.axioms].subtraction_nonzero = Adt.axiom {
  Natural.Subtraction { Natural._x, Natural.Decrement { Natural._y } },
  Natural.Decrement { Natural.Subtraction { Natural._x, Natural._y } }
}
Boolean [Adt.axioms].is_even_zero = Adt.axiom {
  Boolean.Is_even { Natural.Zero {} },
  Boolean.True {}
}
Boolean [Adt.axioms].is_even_nonzero = Adt.axiom {
  Boolean.Is_even { Natural._x },
  Boolean.Not { Boolean.Is_even { Natural.Decrement { Natural._x } } }
}

return Natural
