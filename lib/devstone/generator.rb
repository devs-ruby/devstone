module DEVStone
  class Generator
    attr_reader :width, :depth, :type, :internal_transition_time,
                :external_transition_time

    def initialize(opts={})
      opts = {
        width: 6,
        depth: 3,
        type: :ho,
        internal_transition_time: 0.1,
        external_transition_time: 0.2,
        collide: true,
        maintain_hierarchy: false,
        generate_graph: false
      }.merge(opts)
      @opts = opts

      @model_class = opts[:collide] ? DeterministicAM : StochasticAM
      @width = opts[:width]
      @depth = opts[:depth]
      @type = opts[:type]
      @int_time = opts[:internal_transition_time]
      @ext_time = opts[:external_transition_time]

      @coupled_models_count = 0
      @atomic_models_count = 0
    end

    def build(formalism)
      sb = DEVS::SimulationBuilder.new(@opts)
      sb.duration DEVS::INFINITY
      gen = sb.add_model DEVS::Models::Generators::SequenceGenerator, with_args: [0, 1, 1], name: :gen
      gen.add_output_port :value
      col = sb.add_model DEVS::Models::Collectors::HashCollector, :name => :col
      col.add_input_port :out1
      col.add_input_port :out2 if @type == :ho || @type == :homod
      cmb = sb.add_coupled_model
      cmb.name 'cm_0'
      cmb.add_input_port :in1
      cmb.add_output_port :out1
      if @type == :ho || @type == :homod
        cmb.add_input_port :in2
        cmb.add_output_port :out2
      end
      build_modeling_tree(cmb, 0)
      sb.plug 'gen@value', with: 'cm_0@in1'
      sb.plug 'cm_0@out1', with: 'col@out1'
      if @type == :ho || @type == :homod
        sb.plug 'gen@value', with: 'cm_0@in2'
        sb.plug 'cm_0@out2', with: 'col@out2'
      end
      sb.build
    end

    def build_modeling_tree(pb, level=0)
      case level
      when @depth - 1 # deepest level
        ab = pb.add_model @model_class, name: "am_l#{level}n1".to_sym, with_args: [@int_time, @ext_time]
        ab.add_input_port :in1
        ab.add_output_port :out1
        pb.plug_input_port :in1, with_child: "am_l#{level}n1@in1"
        pb.plug_output_port :out1, with_child: "am_l#{level}n1@out1"

        if @type == :ho || @type == :homod
          ab.add_input_port :in2
          ab.add_output_port :out2
          pb.plug_input_port :in2, with_child: "am_l#{level}n1@in2"
          pb.plug_output_port :out2, with_child: "am_l#{level}n1@out2"
        end
      else            # upper levels
        # add models
        i = 0
        while i < @width-1
          ab = pb.add_model(@model_class, name: "am_l#{level}n#{i+1}".to_sym, with_args: [@int_time, @ext_time])
          ab.add_input_port :in1
          if @type == :hi || @type == :ho
            ab.add_output_port :out1
          end
          if @type == :ho
            ab.add_input_port :in2
            ab.add_output_port :out2
          end
          i+=1
        end
        # if @type == :homod
        #   i = 0
        #   while i < @width
        #     pb.add_model(@model_class, name: "am_l#{level}n#{i+1}")
        #     i += 1
        #   end
        # end
        b = pb.add_coupled_model
        b.name "cm_#{level + 1}"
        b.add_input_port :in1
        b.add_output_port :out1
        if @type == :ho
          b.add_input_port :in2
        end
        build_modeling_tree(b, level + 1)

        # add couplings
        i = 0
        while i < @width-1
          pb.plug_input_port :in1, with_child: "am_l#{level}n#{i+1}@in1"
          i+=1
        end
        if @type == :hi || @type == :ho
          i = 0
          while i < @width-2
            pb.plug "am_l#{level}n#{i+1}@out1", with: "am_l#{level}n#{i+2}@in1"
            i+=1
          end
        end
        if @type == :ho
          pb.plug_input_port :in2, with_child: "am_l#{level}n1@in2"
          pb.plug_output_port :out2, with_child: "am_l#{level}n1@out2"
          pb.plug_input_port :in2, with_child: "cm_#{level + 1}@in2"
        end
        pb.plug_input_port :in1, with_child: "cm_#{level + 1}@in1"
        pb.plug_output_port :out1, with_child: "cm_#{level + 1}@out1"
      end
    end
    private :build_modeling_tree
  end
end
