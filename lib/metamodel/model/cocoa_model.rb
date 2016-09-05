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

    def hash_value
      self.hash.to_s(16)
    end

    def property_key_value_pairs
      @properties.map { |property| "#{property.key.to_s}: #{property.key.to_s}" }.join(", ")
    end

    def property_key_type_pairs
      @properties.map { |property| "#{property.key.to_s}: #{property.type.to_s}" }.join(", ")
    end

    def property_exclude_id_key_value_pairs(prefix = true, cast = false)
      result = ""
      if cast
        result = properties_exclude_id.map { |property| "#{property.key.to_s}: #{property.type_without_optional == "Int" ? "Int(#{property.key.to_s})" : property.key.to_s}" }.join(", ")
      else
        result = properties_exclude_id.map { |property| "#{property.key.to_s}: #{property.key.to_s}" }.join(", ")
      end
      return result unless prefix
      return result.length > 0 ? ", #{result}" : ""
    end

    def property_exclude_id_key_type_pairs(prefix = true)
      result = properties_exclude_id.map { |property| "#{property.key.to_s}: #{property.type.to_s}" }.join(", ")
      return result unless prefix
      return result.length > 0 ? ", #{result}" : ""
    end

    def build_table
      table = "CREATE TABLE #{table_name}"
      main_sql = @properties.map do |property|
        result = "#{property.key} #{property.database_type}"
        result << " NOT NULL" if !property.is_optional?
        result << " PRIMARY KEY" if property.is_primary?
        result << " UNIQUE" if property.is_unique?
        result << " DEFAULT #{property.default_value}" if property.has_default_value?
        result
      end.join(", ")
      main_sql = "(#{main_sql});"
      table + main_sql
    end
  end

end
