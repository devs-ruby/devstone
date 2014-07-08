require 'minitest_helper'

#require 'devs/ext'

require 'pry'
require 'pry-nav'
require 'pry-stack_explorer'

DEVS.logger = Logger.new(STDOUT)
DEVS.logger.level = Logger::DEBUG

class TestDEVStone < MiniTest::Test
  def test_build_modeling_tree
    opts = {
      internal_transition_time: 0,
      external_transition_time: 0,
      depth: 2,
      width: 3,
      type: :hi,
      maintain_hierarchy: false,
      generate_graph: false
    }
    DEVStone.generate_and_simulate(:pdevs, opts)

    assert true
  end
end
