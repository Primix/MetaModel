module MetaModel
  module Record
    class Property
      attr_accessor :name
      attr_reader   :type
      attr_reader   :modifiers

      def initialize(json_key, type = :string, *modifiers)
        @name = json_key.to_s.camelize(:lower)
        @type = convert_symbol_to_type type

        @modifiers = {}
        @modifiers.default = false

        modifiers.flatten.map do |modifier|
          @modifiers[modifier] = true if modifier.is_a? Symbol
          @modifiers[:default] = modifier[:default] if modifier.is_a? Hash and modifier[:default]
        end
      end

      class << self
        def primary_id
          property = Property.new(:privateId, :int, :primary)
          property.name = :privateId
          property
        end
      end

      def type_without_optional
        return type.to_s[0..-2] if type.to_s.end_with? "?"
        type
      end

      def database_type
        case type_without_optional
          when "String" then "TEXT"
          when "Int", "Bool" then "INTEGER"
          when "Double", "NSDate", "Float" then "REAL"
          else raise Informative, "Unsupported type #{self.type}"
        end
      end

      def real_type
        case type_without_optional
        when "String" then "String"
        when "Int", "Bool" then "Int64"
        when "Double", "NSDate", "Float" then "Double"
        else raise Informative, "Unsupported type #{self.type}"
        end
      end

      def convert_symbol_to_type(symbol)
        case symbol
        when :int    then "Int"
        when :double then "Double"
        when :bool   then "Bool"
        when :string then "String"
        when :date   then "NSDate"
        else symbol.to_s.camelize
        end
      end


      def is_array?
        @type.pluralize == str
      end

      def is_unique?
        @modifiers.include? :unique
      end

      def is_primary?
        @modifiers.include? :primary
      end

      def is_foreign?
        @modifiers[:foreign]
      end

      def is_optional?
        @type.to_s.end_with? "?"
      end

      def has_default_value?
        !!@modifiers[:default]
      end

      def default_value
        has_default_value? ? modifiers[:default] : ""
      end

      private
    end
  end
end
