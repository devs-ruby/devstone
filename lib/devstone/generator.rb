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
        maintain_hierarchy: false,
        generate_graph: false
      }.merge(opts)

      @width = opts[:width]
      @depth = opts[:depth]
      @type = opts[:type]
      @internal_transition_time = opts[:internal_transition_time]
      @external_transition_time = opts[:external_transition_time]
      @maintain_hierarchy = opts[:maintain_hierarchy]
      @generate_graph = opts[:generate_graph]

      @coupled_models_count = 0
      @atomic_models_count = 0
    end

    def build(formalism)
      simulation = DEVS.build(formalism, :yield) do |sb|
        sb.maintain_hierarchy! if @maintain_hierarchy
        sb.generate_graph! if @generate_graph

        sb.duration DEVS::INFINITY
        sb.add_model DEVS::Models::Generators::SequenceGenerator, with_args: [0, 1, 1], name: :gen
        sb.add_model DEVS::Models::Collectors::HashCollector, :name => :col
        sb.add_coupled_model do |cmb|
          cmb.name "cm_0"
          build_modeling_tree(cmb, 0)
        end
        sb.plug 'gen@value', with: 'cm_0@in1'
        sb.plug 'gen@value', with: 'cm_0@in2' if @type == :ho || @type == :homod
        sb.plug 'cm_0@out1', with: 'col@out1'
        sb.plug 'cm_0@out2', with: 'col@out2' if @type == :ho || @type == :homod
      end
    end

    def build_modeling_tree(parent_builder, level=0)
      case level
      when @depth - 1 # deepest level
        parent_builder.add_model DEVStone::AtomicModel, name: "am_l#{level}n1".to_sym, with_args: [@internal_transition_time, @external_transition_time]
        parent_builder.plug_input_port :in1, with_child: "am_l#{level}n1@in1"
        parent_builder.plug_output_port :out1, with_child: "am_l#{level}n1@out1"

        if @type == :ho || @type == :homod
          parent_builder.plug_input_port :in2, with_child: "am_l#{level}n1@in2"
          parent_builder.plug_output_port :out2, with_child: "am_l#{level}n1@out2"
        end
      else # upper levels
        (@width - 1).times { |i|
          parent_builder.add_model(DEVStone::AtomicModel, name: "am_l#{level}n#{i+1}".to_sym, with_args: [@internal_transition_time, @external_transition_time])
        }

        if @type == :homod
          @width.times { |i|
            parent_builder.add_model(DEVStone::AtomicModel, name: "am_l#{level}n#{i+1}")
          }
        end

        parent_builder.add_coupled_model do |builder|
          builder.name "cm_#{level + 1}"
          build_modeling_tree(builder, level + 1)
        end

        (@width - 1).times { |i|
          parent_builder.plug_input_port :in1, with_child: "am_l#{level}n#{i+1}@in1"
        }

        if @type == :hi || @type == :ho
          (@width - 2).times { |i|
            parent_builder.plug "am_l#{level}n#{i+1}@out1", with: "am_l#{level}n#{i+2}@in1"
          }
        end

        if @type == :ho
          parent_builder.plug_input_port :in2, with_child: "am_l#{level}n1@in2"
          parent_builder.plug_output_port :out2, with_child: "am_l#{level}n1@out2"
          parent_builder.plug_input_port :in2, with_child: "cm_#{level + 1}@in2"
        end

        parent_builder.plug_input_port :in1, with_child: "cm_#{level + 1}@in1"
        parent_builder.plug_output_port :out1, with_child: "cm_#{level + 1}@out1"
      end
    end
    private :build_modeling_tree
  end
end
