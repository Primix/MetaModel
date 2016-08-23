module MetaModel

  class CocoaProperty
    attr_reader :json_key
    attr_reader :key
    attr_reader :type

    def initialize(json_key, type = :string, **arguments)
      @json_key = json_key
      @key = json_key.to_s.camelize(:lower).to_sym
      @type = type
    end

  end

end
