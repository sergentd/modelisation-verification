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
Boolean [Adt.rules].not_true = Adt.rule {
  Boolean.Not { Boolean.True {} },
  Boolean.False {}
}
Boolean [Adt.rules].not_false = Adt.rule {
  Boolean.Not { Boolean.False {} },
  Boolean.True {},
}

-- TODO: define rules for other operations
-- Equals
Boolean[Adt.rules].equals_true_true = Adt.rule{
  Boolean.Equals{Boolean.True {}, Boolean.True {} },
  Boolean.True {}
}
Boolean[Adt.rules].equals_true_false = Adt.rule{
  Boolean.Equals{Boolean.True {}, Boolean.False {} },
  Boolean.False {}
}
Boolean[Adt.rules].equals_false_true = Adt.rule{
  Boolean.Equals{Boolean.False {}, Boolean.False {} },
  Boolean.False {}
}
Boolean[Adt.rules].equals_false_false = Adt.rule{
  Boolean.Equals{Boolean.False {}, Boolean.False {} },
  Boolean.True {}
}

-- And
Boolean[Adt.rules].and_true_x = Adt.rule{
  Boolean.And{Boolean.True {}, Boolean._x },
  Boolean._x
}
Boolean[Adt.rules].and_false_x = Adt.rule{
  Boolean.And{Boolean.False {}, Boolean._x },
  Boolean.False {}
}
Boolean [Adt.rules].and_x_y = Adt.rule {
  Boolean.And { Boolean._x, Boolean._y },
  Boolean.And { Boolean._y, Boolean._x },
}

-- Or
Boolean [Adt.rules].or_x_y = Adt.rule {
  Boolean.Or { Boolean._x, Boolean._y },
  Boolean.Or { Boolean._y, Boolean._x },
}

Boolean [Adt.rules].or_true_x = Adt.rule {
  Boolean.Or { Boolean.True {}, Boolean._x },
  Boolean.True {},
}

Boolean [Adt.rules].or_false_x = Adt.rule {
  Boolean.Or { Boolean.False {}, Boolean._x },
  Boolean._x,
}

-- Xor
Boolean [Adt.rules].xor_x_y = Adt.rule {
  Boolean.Xor { Boolean._x, Boolean._y },
  Boolean.And { Boolean.Or { Boolean._x, Boolean._y },
                Boolean.Not { Boolean.And { Boolean._x, Boolean._y } } },
}

-- Implies
Boolean [Adt.rules].true_implies_true = Adt.rule {
  Boolean.Implies { Boolean.True {}, Boolean.True {} },
  Boolean.True {},
}

Boolean [Adt.rules].true_implies_false = Adt.rule {
  Boolean.Implies { Boolean.True {}, Boolean.False {} },
  Boolean.False {}
}

Boolean [Adt.rules].false_implies_x = Adt.rule {
  Boolean.Implies { Boolean.False {}, Boolean._x },
  Boolean.True {},
}


return Boolean
