local assert       = require "luassert"
local Ctl          = require "ctl"
local Philosophers = require "petrinet.page24"
local Reachability = require "graph.reachability".create ()

describe ("#ctl", function ()

  it ("can describe a formula", function ()
    assert.is_not_nil (Ctl.Expression.And {
      Ctl.Expression.True {},
      Ctl.Expression.Not {
        Ctl.Expression.Atomic {
          function () return true end,
        },
      },
    })
  end)

  it ("can reduce a formula", function ()
    local function f () return true end
    local formula = Ctl.Expression.AF {
      Ctl.Expression.AG {
        Ctl.Expression.AX {
          Ctl.Expression.Atomic {
            f
          }
        }
      }
    }
    assert.are.equal (Ctl.reduce (formula), Ctl.Expression.Not {
      Ctl.Expression.EG {
        Ctl.Expression.EU {
          Ctl.Expression.True {},
          Ctl.Expression.EX {
            Ctl.Expression.Not {
              Ctl.Expression.Atomic {
                f
              }
            }
          }
        }
      }
    })
  end)

  it ("can prove an atomic proposition", function ()
    local philosophers  = Philosophers (3)
    local true_formula  = Ctl.Expression.Atomic {
      function (marking)
        return marking [philosophers ["thinking-1"]] == 1
      end,
    }
    local false_formula = Ctl.Expression.Atomic {
      function (marking)
        return marking [philosophers ["waiting-1"]] == 1
      end,
    }
    assert.is_truthy (Ctl (true_formula , Reachability (philosophers)))
    assert.is_falsy  (Ctl (false_formula, Reachability (philosophers)))
  end)

  it ("can prove invariants", function ()
    local philosophers  = Philosophers (3)
    local true_formula  = Ctl.Expression.AG {
      Ctl.Expression.Atomic {
        function (marking)
          return marking [philosophers ["thinking-1"]]
               + marking [philosophers ["waiting-1" ]]
               + marking [philosophers ["eating-1"  ]] == 1
        end,
      },
    }
    local false_formula = Ctl.Expression.AG {
      Ctl.Expression.Atomic {
        function (marking)
          return marking [philosophers ["thinking-1"]] == 1
              or marking [philosophers ["thinking-2"]] == 1
              or marking [philosophers ["thinking-3"]] == 1
        end,
      },
    }
    assert.is_truthy (Ctl (true_formula , Reachability (philosophers)))
    assert.is_falsy  (Ctl (false_formula, Reachability (philosophers)))
  end)

  it ("can prove finally", function ()
    local philosophers  = Philosophers (3)
    local true_formula  = Ctl.Expression.AF {
      Ctl.Expression.Atomic {
        function (marking)
          return marking [philosophers ["eating-1"]] == 1
              or marking [philosophers ["eating-2"]] == 1
              or marking [philosophers ["eating-3"]] == 1
        end,
      },
    }
    local false_formula = Ctl.Expression.AF {
      Ctl.Expression.Atomic {
        function (marking)
          return marking [philosophers ["eating-1"]] == 1
        end,
      },
    }
    assert.is_truthy (Ctl (true_formula , Reachability (philosophers)))
    assert.is_falsy  (Ctl (false_formula, Reachability (philosophers)))
  end)

  it ("can prove implication", function ()
    local philosophers  = Philosophers (3)
    local true_formula  = Ctl.Expression.AG {
      Ctl.Expression.Implies {
        Ctl.Expression.Atomic {
          function (marking)
            return marking [philosophers ["thinking-1"]] == 1
          end,
        },
        Ctl.Expression.EF {
          Ctl.Expression.Atomic {
            function (marking)
              return marking [philosophers ["eating-1"]] == 1
            end,
          }
        }
      }
    }
    local false_formula = Ctl.Expression.AG {
      Ctl.Expression.Implies {
        Ctl.Expression.Atomic {
          function (marking)
            return marking [philosophers ["thinking-1"]] == 1
          end,
        },
        Ctl.Expression.AF {
          Ctl.Expression.Atomic {
            function (marking)
              return marking [philosophers ["eating-1"]] == 1
            end,
          }
        }
      }
    }
    assert.is_truthy (Ctl (true_formula , Reachability (philosophers)))
    assert.is_falsy  (Ctl (false_formula, Reachability (philosophers)))
  end)

end)
