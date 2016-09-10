module MetaModel
  module Record
    class Association
      attr_reader :name
      attr_reader :type
      attr_reader :relation
      attr_reader :through
      attr_reader :dependent
      attr_accessor :major_model
      attr_accessor :secondary_model

      def initialize(name, major_model, secondary_model, relation, args)
        through = args[:through]
        dependent = args[:dependent] || :nullify

        @name            = name.to_s.camelize :lower
        @relation        = relation
        @through         = through
        @dependent       = dependent
        @major_model     = major_model
        @secondary_model = secondary_model
      end

      def expect_constraint?(constraint)
        result = true
        result &= self.major_model == constraint.secondary_model
        result &= self.secondary_model == constraint.major_model
        result &= case [self.relation, constraint.relation]
          when [:has_one, :belongs_to], [:has_many, :belongs_to] then true
          when [:belongs_to, :has_many], [:belongs_to, :has_one] then true
          when [:has_many, :has_many] then
            self.through && constraint.through
          else false
        end
        result
      end

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
        when :has_one    then secondary_model.name
        when :has_many   then secondary_model.name
        when :belongs_to then secondary_model.name
        end
      end
    end
  end
end
