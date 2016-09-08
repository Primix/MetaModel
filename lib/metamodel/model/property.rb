module MetaModel

  class Property
    attr_reader :json_key
    attr_accessor :name
    attr_reader :type
    attr_reader :modifiers

    def initialize(json_key, type = :string, *modifiers)
      @json_key = json_key
      @name = json_key.to_s.camelize(:lower).to_sym
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
        property = Property.new(:_id, :int, :primary)
        property.name = :_id
        property
      end
    end

    def type_without_optional
      return type.to_s[0..-2] if type.to_s.end_with? "?"
      type
    end

    def database_type
      lowercase_type = self.type.downcase
      if lowercase_type == "string"
        return "TEXT"
      elsif lowercase_type == "int"
        return "INTEGER"
      elsif lowercase_type == "double"
        return "REAL"
      end
    end

    def real_type
      type_without_optional == "Int" ? "Int64" : type_without_optional
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
      @modifiers.include? :foreign
    end

    def is_optional?
      @type.to_s.end_with? "?"
    end

    def has_one?
      @modifiers.include? :has_one
    end

    def has_many?
      @modifiers.include? :has_many
    end

    def belongs_to?
      @modifiers.include? :belongs_to
    end

    def has_default_value?
      !!@modifiers[:default]
    end

    def default_value
      has_default_value? ? modifiers[:default] : ""
    end

    private

    def convert_symbol_to_type(symbol)
      symbol.to_s.capitalize
    end

  end

end
