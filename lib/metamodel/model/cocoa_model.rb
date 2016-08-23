module MetaModel

  class CocoaModel
    attr_reader :name
    attr_reader :properties

    def initialize(name)
      @name = name
      @properties = []
    end
  end

end
