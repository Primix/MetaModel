module MetaModel

  class CocoaModel
    attr_reader :name
    attr_reader :properties

    def initialize(name)
      @name = name
      @properties = []

      validate
    end

    def properties_exclude_id
      @properties.select { |property| property.key != :id }
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
        property_id = CocoaProperty.new(:id, :int, :primary)
        @properties << property_id
      end
    end

    def build_table
      table = ""
      @properties.each do |property|
        property_key = property.key
        if property.has_default_value?
          default_value = property.default_value
          if default_value.is_a? String
            table << "t.column(#{property_key}, defaultValue: \"#{default_value}\")\n"
          else
            table << "t.column(#{property_key}, defaultValue: #{default_value})\n"
          end
        else
          table << "t.column(#{property_key})\n"
        end
        table << "t.primaryKey(#{property_key})\n" if property.is_primary?
        table << "t.unique(#{property_key})\n" if property.is_unique?
      end
      table
    end
  end

end
