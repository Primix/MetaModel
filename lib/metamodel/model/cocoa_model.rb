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
      name.to_s.tableize
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

    def property_key_value_pairs
      @properties.map { |property| "#{property.key.to_s}: #{property.key.to_s}" }.join(", ")
    end

    def property_key_type_pairs
      @properties.map { |property| "#{property.key.to_s}: #{property.type.to_s}" }.join(", ")
    end

    def property_exclude_id_key_value_pairs
      result = properties_exclude_id.map { |property| "#{property.key.to_s}: #{property.key.to_s}" }.join(", ")
      return result.length > 0 ? ", #{result}" : ""
    end

    def property_exclude_id_key_type_pairs
      result = properties_exclude_id.map { |property| "#{property.key.to_s}: #{property.type.to_s}" }.join(", ")
      return result.length > 0 ? ", #{result}" : ""
    end

    def build_table
      table = ""
      @properties.each do |property|
        property_key = property.key
        if property.has_default_value?
          default_value = property.default_value
          if default_value.is_a? String
            table << "t.column(#{property_key}, defaultValue: \"#{default_value}\")\n\t\t\t"
          else
            table << "t.column(#{property_key}, defaultValue: #{default_value})\n\t\t\t"
          end
        else
          table << "t.column(#{property_key})\n\t\t\t"
        end
        table << "t.primaryKey(#{property_key})\n\t\t\t" if property.is_primary?
        table << "t.unique(#{property_key})\n\t\t\t" if property.is_unique?
      end
      table
    end
  end

end
