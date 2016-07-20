module MetaModel

  class CocoaModel
    attr_reader :model_name
    attr_reader :properties

    def initialize(model_name)
      @model_name = model_name
      @properties = []
    end
  end

end
