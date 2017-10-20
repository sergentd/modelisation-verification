local Adt     = require "adt"
local Boolean = Adt.Sort "bool"

Boolean.True    = {}
Boolean.False   = {}
Boolean.Equals  = { Boolean, Boolean }
Boolean.Not     = { Boolean }
Boolean.And     = { Boolean, Boolean }
Boolean.Or      = { Boolean, Boolean }
Boolean.Xor     = { Boolean, Boolean }
Boolean.Implies = { Boolean, Boolean }

Boolean.generators { Boolean.True, Boolean.False }

-- Not
Boolean [Adt.axioms].not_true = Adt.axiom {
  Boolean.Not { Boolean.True {} },
  Boolean.False {}
}
Boolean [Adt.axioms].not_false = Adt.axiom {
  Boolean.Not { Boolean.False {} },
  Boolean.True {}
}

-- TODO: define axioms for other operations

-- Equal
Boolean[Adt.axioms].eq_true_true = Adt.axiom {
  Boolean.Equals {Boolean.True {}, Boolean.True {}},
  Boolean.True {}
}
Boolean[Adt.axioms].eq_true_false = Adt.axiom {
  Boolean.Equals {Boolean.True {}, Boolean.False {}},
  Boolean.False {}
}
Boolean[Adt.axioms].eq_x_y = Adt.axiom {
  Boolean.Equals {Boolean._x, Boolean._y},
  Boolean.Equals {Boolean._y, Boolean._x}
}

-- And
Boolean[Adt.axioms].and_true_x = Adt.axiom {
  Boolean.And { Boolean.True {}, Boolean._x },
  Boolean._x
}
Boolean[Adt.axioms].and_false_x = Adt.axiom {
  Boolean.And { Boolean.False {}, Boolean._x },
  Boolean.False {}
}
Boolean[Adt.axioms].and_x_y = Adt.axiom {
  Boolean.And { Boolean._x, Boolean._y },
  Boolean.And { Boolean._y, Boolean._x }
}

-- Or
Boolean[Adt.axioms].or_true_x = Adt.axiom {
  Boolean.Or { Boolean.True {}, Boolean._x },
  Boolean.True {}
}
Boolean[Adt.axioms].or_false_x = Adt.axiom {
  Boolean.Or { Boolean.False {}, Boolean._x },
  Boolean._x
}
Boolean[Adt.axioms].or_x_y = Adt.axiom {
  Boolean.Or { Boolean._x, Boolean._y },
  Boolean.Or { Boolean._y, Boolean._x}
}

-- Xor
Boolean[Adt.axioms].xor_true_x = Adt.axiom {
  Boolean.Xor {Boolean.True {}, Boolean._x },
  Boolean.Not {Boolean._x}
}
Boolean[Adt.axioms].xor_false_x = Adt.axiom {
  Boolean.Xor {Boolean.False {}, Boolean._x },
  Boolean._x
}
Boolean[Adt.axioms].or_x_y = Adt.axiom {
  Boolean.Xor { Boolean._x, Boolean._y },
  Boolean.Xor { Boolean._y, Boolean._x}
}

-- Implies

return Boolean
