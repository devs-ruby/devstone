require 'devs'
require 'devs/models'

require 'devstone/version'
require 'devstone/dhrystone'
require 'devstone/deterministic'
require 'devstone/stochastic'
require 'devstone/generator'

module DEVStone
  class << self
    attr_accessor :random
  end
  @random = Random.new

  def generate(formalism, opts={})
    Generator.new(opts).build(formalism)
  end
  module_function :generate

  def generate_and_simulate(formalism, opts={})
    Generator.new(opts).build(formalism).simulate
  end
  module_function :generate_and_simulate
end
