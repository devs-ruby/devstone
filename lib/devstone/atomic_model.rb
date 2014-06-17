module DEVStone
  class AtomicModel < DEVS::AtomicModel
    def initialize(int_time, ext_time)
      super()
      @internal_transition_time = int_time
      @external_transition_time = ext_time
    end

    def external_transition(messages)
      @payload = messages.first.payload
      Dhrystone.run_for(@external_transition_time)
      @sigma = 1
    end

    def internal_transition
      Dhrystone.run_for(@internal_transition_time)
      @sigma = DEVS::INFINITY
    end

    def output
      output_ports.each { |port| post(@payload, port) }
    end
  end
end
