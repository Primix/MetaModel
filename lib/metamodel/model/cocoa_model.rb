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

    def relation_name
      "#{name}Relation"
    end

    def validate
      property_keys = @properties.map { |property| property.key }
      
      unless property_keys.include? :id
        property_id = CocoaProperty.new(id, :int, :primary)
        @properties << property_id
      end
    end
  end

end
