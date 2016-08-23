module MetaModel

  class CocoaProperty
    attr_reader :json_key
    attr_reader :property_key
    attr_reader :property_type

    def initialize(json_key, property_type = :string, **arguments)
      @json_key = json_key
      @property_key = json_key.to_s.camelize(:lower).to_sym
      @property_type = property_type
    end

  end

end
