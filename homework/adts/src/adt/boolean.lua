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
  Boolean.True {},
}

-- TODO: define axioms for other operations

return Boolean
