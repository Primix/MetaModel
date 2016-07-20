module MetaModel

  class PropertyConstructor

    attr_reader :model

    define_method :string do |json_key, property_key = nil|
      save_property CocoaProperty.new(json_key, :string, property_key)
    end

    def initialize(model)
      @model = model
    end

    def method_missing(symbol, *arguments)
      define_method symbol do |json_key, property_key = nil|
        save_property CocoaProperty.new(json_key, symbol, property_key)
      end
      eval symbol, arguments
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
