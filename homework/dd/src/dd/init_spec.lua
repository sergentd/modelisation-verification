local assert = require "luassert"

describe ("decision diagrams", function ()

  it ("can create and sum terminals", function ()
    local variables = { false }
    local Dd = require "dd" (variables)
    assert.are.equal (Dd.terminal (false) + Dd.terminal (false), Dd.terminal (false))
    assert.are.equal (Dd.terminal (false) + Dd.terminal (true ), Dd.terminal (true ))
    assert.are.equal (Dd.terminal (true ) + Dd.terminal (false), Dd.terminal (true ))
    assert.are.equal (Dd.terminal (true ) + Dd.terminal (true ), Dd.terminal (true ))
  end)

  it ("can create dd from mapping", function ()
    local variables = { 1, 2 }
    local Dd = require "dd" (variables)
    local created = Dd.create {
      [1] = true,
      [2] = false,
    }
    assert.are.equal (created, Dd.node {
      variable = 1,
      [true ] = Dd.node {
        variable = 2,
        [true ] = Dd.terminal (false),
        [false] = Dd.terminal (true),
      },
      [false] = Dd.terminal (false),
    })
  end)

  it ("can use union", function ()
    local variables = { 1 }
    local Dd = require "dd" (variables)
    local d1 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (false),
    }
    local d2 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (false),
      [false]  = Dd.terminal (true ),
    }
    assert.are.equal (d1 + d2, Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true),
      [false]  = Dd.terminal (true),
    })
  end)

  it ("can use intersection", function ()
    local variables = { 1 }
    local Dd = require "dd" (variables)
    local d1 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (false),
    }
    local d2 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (true ),
    }
    assert.are.equal (d1 * d2, Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (false),
    })
  end)

  it ("can use difference", function ()
    local variables = { 1 }
    local Dd = require "dd" (variables)
    local d1 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (true ),
    }
    local d2 = Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (true ),
      [false]  = Dd.terminal (false),
    }
    assert.are.equal (d1 - d2, Dd.node {
      variable = 1,
      [true ]  = Dd.terminal (false),
      [false]  = Dd.terminal (true ),
    })
  end)

  it ("can use intersection with don't care", function ()
    local variables = { 1, 2 }
    local Dd = require "dd" (variables)
    local d1 = Dd.node {
      variable = 2,
      [true ]  = Dd.terminal (true),
      [false]  = Dd.terminal (true),
    }
    local d2 = Dd.node {
      variable = 1,
      [true ]  = d1,
      [false]  = d1,
    }
    local d3 = Dd.node {
      variable = 2,
      [true ] = Dd.terminal (true ),
      [false] = Dd.terminal (false),
    }
    local d4 = d2 * d3
    assert.are.equal (d2 * d3, Dd.node {
      variable = 1,
      [true ]  = d4,
      [false]  = d4,
    })
  end)

  describe ("operations", function ()

    local Dd
    local dd1, dd2, dd

    before_each (function ()
      Dd  = require "dd" { 1, 2, 3, 4, 5 }
      dd1 = Dd.create {
        [1] = true,
        [2] = false,
        [3] = true,
        [4] = false,
        [5] = true,
      }
      dd2 = Dd.create {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
      }
      dd  = dd1 + dd2
    end)

    it ("can apply constant", function ()
      assert.are.equal (Dd.constant (dd1) (dd), dd1)
    end)

    it ("can apply identity", function ()
      assert.are.equal (Dd.identity () (dd), dd)
    end)

    it ("can apply filter", function ()
      assert.are.equal (Dd.filter (function (x)
        return not x [2]
      end) (dd), dd1)
    end)

    it ("can apply map", function ()
      assert.are.equal (Dd.map (function (x)
        return {
          [1] = x [1],
          [2] = false,
          [3] = x [3],
          [4] = false,
          [5] = x [5],
        }
      end) (dd), dd1)
    end)

    it ("can apply composition", function ()
      local o = Dd.filter (function (x)
        return not x [2]
      end) .. Dd.map (function (x)
        return {
          [1] = x [1],
          [2] = x [2],
          [3] = x [3],
          [4] = true,
          [5] = x [5],
        }
      end)
      assert.are.equal (o (dd), Dd.create {
        [1] = true,
        [2] = false,
        [3] = true,
        [4] = true,
        [5] = true,
      })
    end)

    it ("can apply union", function ()
      local o1 = Dd.union { Dd.identity (), Dd.constant (dd2) }
      local o2 = Dd.identity () + Dd.constant (dd2)
      assert.are.equal (o1 (dd1), dd1 + dd2)
      assert.are.equal (o2 (dd1), dd1 + dd2)
    end)

    it ("can apply intersection", function ()
      local o1 = Dd.intersection { Dd.identity (), Dd.constant (dd2) }
      local o2 = Dd.identity () * Dd.constant (dd2)
      assert.are.equal (o1 (dd), dd * dd2)
      assert.are.equal (o2 (dd), dd * dd2)
    end)

    it ("can apply difference", function ()
      local o1 = Dd.difference { Dd.identity (), Dd.constant (dd2) }
      local o2 = Dd.identity () - Dd.constant (dd2)
      assert.are.equal (o1 (dd), dd - dd2)
      assert.are.equal (o2 (dd), dd - dd2)
    end)

    it ("can apply fixpoint", function ()
      local o = Dd.fixpoint (Dd.identity () + Dd.map (function (x)
        if not x [2] then
          x [2] = true
          return x
        elseif not x [4] then
          x [4] = true
          return x
        end
      end))
      local dd3 = Dd.create {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = false,
        [5] = true,
      }
      assert.are.equal (o (dd1), dd1 + dd2 + dd3)
    end)

  end)

end)
