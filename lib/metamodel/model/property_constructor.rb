module MetaModel

  class PropertyConstructor

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def string(json_key, property_key = nil)
      @model.properties << CocoaProperty.new(json_key, "String", property_key)
    end

  end

end
