module MetaModel

  class CocoaProperty
    attr_reader :json_key
    attr_reader :key
    attr_reader :type

    def initialize(json_key, type = :string, *modifiers)
      @json_key = json_key
      @key = json_key.to_s.camelize(:lower).to_sym
      @type = convert_symbol_to_type type
      p modifiers
    end

    def convert_symbol_to_type(symbol)
      symbol.to_s.capitalize
    end

  end

end
