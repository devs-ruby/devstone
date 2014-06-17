require 'devs'
require 'devs/models'

require 'devstone/version'
require 'devstone/dhrystone'
require 'devstone/atomic_model'
require 'devstone/generator'

module DEVStone
  def generate_and_simulate(formalism, opts={})
    Generator.new(opts).simulate(formalism)
  end
  module_function :generate_and_simulate
end
