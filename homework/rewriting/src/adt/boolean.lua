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

return Boolean
