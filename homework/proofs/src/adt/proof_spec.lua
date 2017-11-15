describe ("#theorem", function ()

  it ("can prove that x+y = y+x", function ()
    -- TODO
    local Adt     = require "adt"
    local Natural = require "adt.natural"
    local Theorem = require "adt.theorem"
    local t1 = Theorem.axiom (Natural [Adt.axioms].addition_zero)
    local t2 = Theorem.axiom (Natural [Adt.axioms].addition_nonzero)
    local conjecture1 = Theorem.Conjecture {
      Natural.Addition { Natural._y, Natural.Zero {} },
      Natural.Addition { Natural.Zero {}, Natural._y }
    }
    local conjecture2 = Theorem.Conjecture {
      Natural.Addition { Natural._x, Natural._y },
      Natural.Addition { Natural._y, Natural._x }
    }
    local theoremy0 = Theorem.inductive (conjecture1, conjecture1.variables [Natural._y], {
      [Natural.Zero] = function ()
        local init1 = Theorem.substitution (t1, t1[1][1], Natural.Zero {} )
        local init2 = Theorem {
          Natural.Zero {},
          Natural.Addition {Natural.Zero {}, Natural.Zero {}}
        }
        return Theorem.transitivity(init1, init2)
      end,
      [Natural.Successor] = function (t)
        local t3 = Theorem.substitutivity (Natural.Successor, {t})
        local t4 = Theorem.substitution   (t2, t2.variables [Natural._x])
        local t5 = Theorem.transitivity   (t3, Theorem.symmetry (t4))
        local t6 = Theorem.substitutivity (Natural.Successor, {t1})
        local t7 = Theorem.transitivity   (Theorem.symmetry (t5), t6)
        local t8 = Theorem.substitution   (t1, t1.variables [Natural._x])
        local t9 = Theorem.transitivity   (t7, Theorem.symmetry (t8))
        return Theorem.symmetry (t9)
      end
    })
  end)

end)
