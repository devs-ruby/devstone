module DEVStone
  class StochasticAM < DEVS::AtomicModel
    def initialize(int_time, ext_time)
      super()
      @int_time = int_time
      @ext_time = ext_time
    end

    def external_transition(messages)
      @payload = messages.first.payload
      ext_time = @ext_time
      Dhrystone.run_for(ext_time) if ext_time > 0
      @sigma = rand(100 - 1) + 1 #DEVStone::Random.rand
    end

    def internal_transition
      int_time = @int_time
      Dhrystone.run_for(int_time) if int_time > 0
      @sigma = DEVS::INFINITY
    end

    def output
      i = 0
      while i < output_ports.count
        post(@payload, output_ports[i])
        i += 1
      end
    end
  end
end
