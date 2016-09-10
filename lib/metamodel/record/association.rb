module MetaModel
  module Record
    class Association
      attr_reader :name
      attr_reader :type
      attr_reader :relation
      attr_reader :through
      attr_accessor :major_model
      attr_accessor :secondary_model

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

      def type
        case @relation
        when :has_one    then secondary_model.name
        when :has_many   then secondary_model.name
        when :belongs_to then major_model.name
        end
      end
    end
  end
end
