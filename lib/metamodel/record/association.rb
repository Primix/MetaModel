module MetaModel
  module Record
    class Association
      attr_reader :name
      attr_reader :type
      attr_reader :relation
      attr_reader :dependent
      attr_accessor :major_model
      attr_accessor :secondary_model
      attr_accessor :through

      def initialize(name, major_model, secondary_model, relation, args)
        through = args[:through]
        dependent = args[:dependent] || :nullify

        @name            = name.to_s.camelize :lower
        @relation        = relation
        @through         = through.to_s.camelize.singularize unless through.nil?
        @dependent       = dependent
        @major_model     = major_model
        @secondary_model = secondary_model

        validate_association
      end

      def expect_constraint?(constraint)
        result = true
        result &= self.major_model == constraint.secondary_model
        result &= self.secondary_model == constraint.major_model
        result &= self.through == constraint.through

        result &= case [self.relation, constraint.relation]
          when [:has_one, :belongs_to], [:belongs_to, :has_one] then true
          when [:belongs_to, :has_many] then
            return false if self.dependent == :destroy
            return true unless constraint.through
            return false
          when [:has_many, :belongs_to] then
            return false if constraint.dependent == :destroy
            return true unless self.through
            return false
          when [:has_many, :has_many] then
            self.through == constraint.through
          else false
        end
        result
      end

      def secondary_model_instance
        case relation
        when :has_many, :has_one then "#{secondary_model.name}.find(id)"
        when :belongs_to then "#{secondary_model.name}.find(#{secondary_model.foreign_id})"
        else ""
        end
      end

      #-------------------------------------------------------------------------#

      # @!group Validation

      def validate_association
        validate_dependent(@dependent)
        validate_through(@through)
      end

      def validate_dependent(dependent)
        supported_dependent_options = [:nullify, :destroy]
        raise Informative, "Unknown dependent option #{dependent}, \
          MetaModel only supports #{supported_dependent_options} now" \
          unless supported_dependent_options.include? dependent
      end

      def validate_through(through)
        raise Informative, "belongs_to can't coexist with through." \
          if !!through && @relation == :belongs_to
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
        if through
          "#{major_model.name}.#{relation}.#{secondary_model.name}.through.#{through.name}.#{dependent}"
        else
          "#{major_model.name}.#{relation}.#{secondary_model.name}.#{dependent}"
        end
      end
    end
  end
end
