module MetaModel

  class CocoaProperty
    attr_reader :json_key
    attr_reader :key
    attr_reader :type
    attr_reader :modifiers

    def initialize(json_key, type = :string, *modifiers)
      @json_key = json_key
      @key = json_key.to_s.camelize(:lower).to_sym
      @type = convert_symbol_to_type type

      @modifiers = {}
      @modifiers.default = false

      modifiers.flatten.map do |modifier|
        @modifiers[modifier] = true if modifier.is_a? Symbol
        @modifiers[:default] = modifier[:default] if modifier.is_a? Hash and modifier[:default]
      end
    end

    def is_unique?
      @modifiers.include? :unique
    end

    def is_primary?
      @modifiers.include? :primary
    end

    def is_optional?
      @type.to_s.end_with? "?"
    end

    def has_default_value?
      @modifiers[:default].nil?
    end

    def default_value
      modifiers[:default]
    end

    private

    def convert_symbol_to_type(symbol)
      symbol.to_s.capitalize
    end

  end

end
