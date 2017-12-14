local assert  = require "luassert"
local PetriDd = require "dd.petrinet"

describe ("dds can generate the state space of Petri nets", function ()

  it ("for #page21", function ()
    local petridd = PetriDd (require "petrinet.page21")
    local states  = petridd.paths (petridd.generate (petridd.initial))
    petridd.show (states)
    assert.are.equal (#states, 2)
  end)

  it ("for #page24", function ()
    local petridd = PetriDd (require "petrinet.page24" (3))
    local states  = petridd.paths (petridd.generate (petridd.initial))
    petridd.show (states)
    assert.are.equal (#states, 14)
  end)

  it ("for #page47", function ()
    local petridd = PetriDd (require "petrinet.page47")
    local states  = petridd.paths (petridd.generate (petridd.initial))
    petridd.show (states)
    assert.are.equal (#states, 5)
  end)

  it ("for #page90", function ()
    local petridd = PetriDd (require "petrinet.page90")
    local states  = petridd.paths (petridd.generate (petridd.initial))
    assert.are.equal (#states, 1)
  end)

  it ("for #page92", function ()
    local petridd = PetriDd (require "petrinet.page92")
    local states  = petridd.paths (petridd.generate (petridd.initial))
    petridd.show (states)
    assert.are.equal (#states, 4)
  end)

end)
