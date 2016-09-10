module MetaModel
  module Record
    class Association
      attr_reader :name
      attr_reader :relation
      attr_reader :major_model
      attr_reader :secondary_model
      attr_reader :through

      def initialize(name, major_model, secondary_model, relation, through = nil)
        @name            = name.to_s.camelize :lower
        @relation        = relation
        @through         = through
        @major_model     = major_model
        @secondary_model = secondary_model
      end

      def has_one?
        @relation == :has_one
      end

      def has_many?
        @modifiers == :has_many
      end

      def belongs_to?
        @modifiers == :belongs_to
      end
    end
  end
end
