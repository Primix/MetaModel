module MetaModel

  class PropertyConstructor

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def string(json_key, property_key = nil)
      save_property CocoaProperty.new(json_key, "String", property_key)
    end

    private

    # Save property to current Cocoa Model
    #
    # @param [CocoaProperty] the instance for cocoa property
    # @return [Void]
    def save_property(property)
      @model.properties << property
    end
  end

end
