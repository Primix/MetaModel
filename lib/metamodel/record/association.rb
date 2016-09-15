module MetaModel
  module Record
    class Association
      attr_reader :name
      attr_reader :type
      attr_reader :relation
      attr_reader :dependent
      attr_accessor :major_model
      attr_accessor :secondary_model

      def initialize(name, major_model, secondary_model, relation, args)
        dependent = args[:dependent] || :nullify

        @name            = name.to_s.camelize :lower
        @relation        = relation
        @dependent       = dependent
        @major_model     = major_model
        @secondary_model = secondary_model

        validate_association
      end

      def class_name
        "#{major_model.name}#{secondary_model.name}Association".camelize
      end

      def reverse_class_name
        "#{secondary_model.name}#{major_model.name}Association".camelize
      end

      def major_model_id
        major_model.foreign_id
      end

      def secondary_model_id
        secondary_model.foreign_id
      end

      def expect_constraint?(constraint)
        result = true
        result &= self.major_model == constraint.secondary_model
        result &= self.secondary_model == constraint.major_model

        result &= case [self.relation, constraint.relation]
          when [:has_one, :belongs_to], [:belongs_to, :has_one] then true
          when [:belongs_to, :has_many] then
            return false if self.dependent == :destroy
            return true
          when [:has_many, :belongs_to] then
            return false if constraint.dependent == :destroy
            return true
          when [:has_many, :has_many] then
            return true
          else false
        end
        result
      end

      #-------------------------------------------------------------------------#

      # @!group Validation

      def validate_association
        validate_dependent(@dependent)
      end

      def validate_dependent(dependent)
        supported_dependent_options = [:nullify, :destroy]
        raise Informative, "Unknown dependent option #{dependent}, \
          MetaModel only supports #{supported_dependent_options} now" \
          unless supported_dependent_options.include? dependent
      end

      #-------------------------------------------------------------------------#

      # @!group Relation

      def has_one?
        @relation == :has_one
      end

      def has_many?
        @relation == :has_many
      end

      def belongs_to?
        @relation == :belongs_to
      end

      def type
        case @relation
        when :has_one, :has_many, :belongs_to then secondary_model.name
        end
      end

      def debug_description
        "#{major_model.name}.#{relation}.#{secondary_model.name}.#{dependent}"
      end
    end
  end
end
