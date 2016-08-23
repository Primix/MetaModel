module MetaModel

  class CocoaModel
    attr_reader :name
    attr_reader :properties

    def initialize(name)
      @name = name
      @properties = []
    end

    def table_name
      name.to_s.pluralize.underscore
    end
  end

end
