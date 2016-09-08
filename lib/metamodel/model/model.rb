module MetaModel

  class Model
    attr_reader :name
    attr_reader :properties
    attr_reader :relation_properties

    def initialize(name)
      @name = name
      @properties = []
      @relation_properties = []

      validate
    end

    def properties_exclude_id
      @properties.select { |property| property.name != :id }
    end

    def table_name
      name.to_s.tableize
    end

    def relation_name
      "#{name}Relation"
    end

    def validate
      property_keys = @properties.map { |property| property.name }

      unless property_keys.include? :id
        property_id = Property.new(:id, :int, :primary, :default => -1)
        @properties << property_id
      end
    end

    def hash_value
      self.hash.to_s(16)
    end

    def property_key_value_pairs
      @properties.map { |property| "#{property.name.to_s}: #{property.name.to_s}" }.join(", ")
    end

    def property_key_type_pairs
      key_type_pairs_with_property(@properties, false)
    end

    def property_exclude_id_key_value_pairs(prefix = true, cast = false)
      result = ""
      if cast
        result = properties_exclude_id.map { |property| "#{property.name.to_s}: #{property.type_without_optional == "Int" ? "Int(#{property.name.to_s})" : property.name.to_s}" }.join(", ")
      else
        result = properties_exclude_id.map { |property| "#{property.name.to_s}: #{property.name.to_s}" }.join(", ")
      end
      return result unless prefix
      return result.length > 0 ? ", #{result}" : ""
    end

    def property_exclude_id_key_type_pairs(prefix = true)
      key_type_pairs_with_property(properties_exclude_id, prefix)
    end

    def key_type_pairs_with_property(properties, prefix = true)
      result = properties.map { |property|
        has_default_value = property.has_default_value?
        default_value = property.type_without_optional == "String" ?
          "\"#{property.default_value}\"" : property.default_value
        "#{property.name.to_s}: #{property.type.to_s}#{if has_default_value then " = " + "#{default_value}" end}"
      }.join(", ")
      return result unless prefix
      return result.length > 0 ? ", #{result}" : ""
    end

    def build_table
      table = "CREATE TABLE #{table_name}"
      main_sql = @properties.map do |property|
        result = "#{property.name} #{property.database_type}"
        result << " NOT NULL" if !property.is_optional?
        result << " PRIMARY KEY" if property.is_primary?
        result << " UNIQUE" if property.is_unique?
        result << " DEFAULT #{property.default_value}" if property.has_default_value?
        result
      end
      foreign_sql = @properties.map do |property|
        next unless property.is_foreign?
        reference_table_name = property.type.tableize
        "FOREIGN KEY(#{property.name}) REFERENCES #{reference_table_name}(id)"
      end

      table + "(#{(main_sql + foreign_sql).compact.join(", ")});"
    end
  end

end
