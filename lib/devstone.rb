require 'devs'
require 'devs/models'

require 'devstone/version'
require 'devstone/dhrystone'
require 'devstone/atomic_model'
require 'devstone/generator'

module DEVStone
  def generate(formalism, opts={})
    Generator.new(opts).build(formalism)
  end
  module_function :generate

  def generate_and_simulate(formalism, opts={})
    Generator.new(opts).build(formalism).simulate
  end
  module_function :generate_and_simulate
end
