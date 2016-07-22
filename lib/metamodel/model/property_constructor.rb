module MetaModel

  class PropertyConstructor

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def method_missing(meth, *arguments, &block)
      (class << self; self; end).class_eval do
        define_method meth do |json_key, property_key = nil|
          save_property CocoaProperty.new(json_key, meth, property_key)
        end
      end
      self.send meth, *arguments
    end

    private

    # Save property to current Cocoa Model
    #
    # @param [CocoaProperty] the instance for cocoa property
    # @return [Void]
    def save_property(property)
      @model.properties << property
      p property
    end
  end

end
