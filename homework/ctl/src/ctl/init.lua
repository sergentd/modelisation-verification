local Adt   = require "adt"
local State = require "state"
local Fun   = require "fun"

local Ctl = setmetatable ({}, {})

local Expression = Adt.Sort "expression"

Expression.Atomic  = { "function" }
Expression.True    = {}
Expression.False   = {}
Expression.Not     = { Expression }
Expression.And     = { Expression, Expression }
Expression.Or      = { Expression, Expression }
Expression.Implies = { Expression, Expression }
Expression.AX      = { Expression }
Expression.EX      = { Expression }
Expression.AF      = { Expression }
Expression.EF      = { Expression }
Expression.AG      = { Expression }
Expression.EG      = { Expression }
Expression.AU      = { Expression, Expression }
Expression.EU      = { Expression, Expression }
Expression.AW      = { Expression, Expression }
Expression.EW      = { Expression, Expression }

Expression.generators {
  Expression.Atomic,
  Expression.True,
  Expression.Not,
  Expression.Or,
  Expression.EX,
  Expression.EG,
  Expression.EU,
}

Ctl.Expression = Expression

Expression [Adt.rules].False = Adt.rule {
  Expression.False {},
  Expression.Not {
    Expression.True {},
  },
}

Expression [Adt.rules].Not_not = Adt.rule {
  Expression.Not {
    Expression.Not {
      Expression._e,
    },
  },
  Expression._e,
}

Expression [Adt.rules].Implies = Adt.rule {
  Expression.Implies {
    Expression._x,
    Expression._y,
  },
  Expression.Or {
    Expression.Not {
      Expression._x,
    },
    Expression._y,
  },
}

Expression [Adt.rules].And = Adt.rule {
  Expression.And {
    Expression._x,
    Expression._y,
  },
  Expression.Not {
    Expression.Or {
      Expression.Not {
        Expression._x,
      },
      Expression.Not {
        Expression._y,
      },
    },
  }
}

Expression [Adt.rules].AX = Adt.rule {
  Expression.AX {
    Expression._e,
  },
  -- TODO
  Expression.Not {
    Expression.EX {
      Expression.Not {
        Expression._e
      }
    }
  }
}

Expression [Adt.rules].AG = Adt.rule {
  Expression.AG {
    Expression._e,
  },
  -- TODO
  Expression.Not {
    Expression.EF {
      Expression.Not {
        Expression._e
      }
    }
  }
}

Expression [Adt.rules].AF = Adt.rule {
  Expression.AF {
    Expression._e,
  },
  -- TODO
  Expression.Not {
    Expression.EG {
      Expression.Not {
        Expression._e
      }
    }
  }
}

Expression [Adt.rules].EF = Adt.rule {
  Expression.EF {
    Expression._e,
  },
  -- TODO
  Expression.EU {
    Expression.True {},
    Expression._e
  }
}

Expression [Adt.rules].AU = Adt.rule {
  Expression.AU {
    Expression._x,
    Expression._y,
  },
  -- TODO
  Expression.And {
    Expression.AF {
      Expression._y
    },
    Expression.AW {
      Expression._x,
      Expression._y
    }
  }
}

Expression [Adt.rules].EW = Adt.rule {
  Expression.EW {
    Expression._x,
    Expression._y,
  },
  -- TODO
  Expression.Or {
    Expression.EG {
      Expression._x
    },
    Expression.EU {
      Expression._x,
      Expression._y
    }
  }
}

Expression [Adt.rules].AW = Adt.rule {
  Expression.AW {
    Expression._x,
    Expression._y,
  },
  -- TODO
  Expression.Not {
    Expression.EU {
      Expression.Not {
        Expression._y
      },
      Expression.Not {
        Expression.Or {
          Expression._x,
          Expression._y
        }
      }
    }
  }
}

function Ctl.reduce (formula)
  assert (getmetatable (formula) == Adt.Term and formula [Adt.Sort] == Expression,
          "formula must be a CTL one")
  local rules = {}
  for _, v in pairs (Expression [Adt.rules]) do
    rules [#rules+1] = Adt.Strategy.rule (v)
  end
  return Adt.Strategy.innermost (Adt.Strategy.choice (rules)) (formula)
end

function Ctl.compute (formula, initial, states)
  assert (getmetatable (formula) == Adt.Term and formula [Adt.Sort] == Expression,
          "formula must be a CTL one")
  assert (getmetatable (initial) == State,
          "initial must be a state")
  assert (type (states) == "table",
          "states must be a table of states")
  if formula [Adt.Operation] == Expression.Atomic then
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = formula [1] (state.marking)
    end)
  elseif formula [Adt.Operation] == Expression.True then
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = true
    end)
  elseif formula [Adt.Operation] == Expression.Not then
    Ctl.compute (formula [1], initial, states)
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = not state.properties [formula [1]]
    end)
  elseif formula [Adt.Operation] == Expression.Or then
    -- TODO
    Fun.fromtable (formula):each (function (subformula)
      Ctl.compute (subformula, initial, states)
    end)
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = Fun.fromtable (formula)
      : any (function (subformula) return state.properties [subformula] end)
    end)
  elseif formula [Adt.Operation] == Expression.EX then
    Ctl.compute (formula [1], initial, states)
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = Fun.frommap (state.successors)
      : any (function (_, successor) return successor.properties [formula [1]] end)
    end)
  elseif formula [Adt.Operation] == Expression.EG then
    -- TODO
    Ctl.compute (formula [1], initial, states)
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = state.properties [formula [1]]
    end)
    local tmp
    local fixpoint
    repeat
      fixpoint = true
      Fun.fromtable (states):each (function (state)
        tmp = Fun.frommap (state.successors)
        : any (function (_, successor) return successor.properties [formula [1]] end)
        tmp = tmp and state.properties [formula]
        if tmp ~= state.properties [formula] then
          state.properties [formula] = tmp
          fixpoint = false
        end
      end)
    until fixpoint
  elseif formula [Adt.Operation] == Expression.EU then
    -- TODO
    Ctl.compute (formula [1], initial, states)
    Ctl.compute (formula [2], initial, states)
    Fun.fromtable (states):each (function (state)
      state.properties [formula] = state.properties [formula [2]]
    end)
    local tmp
    local fixpoint
    repeat
      fixpoint = true
      Fun.fromtable (states):each (function (state)
        if state.properties [formula [1]] == true
       and state.properties [formula]     == false then
          tmp = Fun.frommap (state.successors)
          : any (function (_, successor) return successor.properties [formula [1]] end)
          if tmp then
            state.properties [formula] = true
            fixpoint = false
          end
        end
      end)
    until fixpoint
  else
    assert (false)
  end
  return initial.properties [formula]
end

getmetatable (Ctl).__call = function (_, formula, initial, states)
  return Ctl.compute (Ctl.reduce (formula), initial, states)
end

return Ctl
