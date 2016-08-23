module MetaModel

  class CocoaProperty
    attr_reader :json_key
    attr_reader :property_key
    attr_reader :property_type

    def initialize(json_key, property_type, **arguments)
      @property_key = json_key.camelize(:lower)
      @json_key = json_key
      @property_type = property_type
      puts arguments
    end

  end

end
