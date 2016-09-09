module MetaModel

  class Model
    attr_reader :name
    attr_reader :properties
    attr_reader :relation_properties

    def initialize(name)
      @name = name.to_s
      @properties = []
      @relation_properties = []

      validate
    end

    def properties_exclude_id
      @properties.select { |property| property.name != "id" }
    end

    def foreign_id
      "#{name}_id".camelize(:lower)
    end

    def table_name
      name.tableize
    end

    def relation_name
      "#{name}Relation"
    end

    def all_properties
      all_properties = properties.clone
      all_properties.push Property.primary_id
      all_properties
    end

    def validate
      property_keys = @properties.map { |property| property.name }

      unless property_keys.include? "id"
        property_id = Property.new(:id, :int, :unique, :default => 0)
        @properties << property_id
      end
    end

    def hash_value
      self.hash.to_s(16)
    end

    def property_key_value_pairs(cast = false)
      key_value_pairs_with_property @properties, cast
    end

    def property_key_value_pairs_without_property(property)
      key_value_pairs_with_property @properties.select { |element| element.name != property }
    end

    def property_exclude_id_key_value_pairs(cast = false)
      key_value_pairs_with_property properties_exclude_id, cast
    end

    def property_key_type_pairs
      key_type_pairs_with_property @properties
    end

    def property_key_type_pairs_without_property(property)
      key_type_pairs_with_property @properties.select { |element| element.name != property }
    end

    def property_exclude_id_key_type_pairs
      key_type_pairs_with_property properties_exclude_id
    end

    def build_table
      table = "CREATE TABLE #{table_name}"
      main_sql = @properties.map do |property|
        result = "#{property.name} #{property.database_type}"
        result << " PRIMARY KEY" if property.is_primary?
        result << " UNIQUE" if property.is_unique?
        result << " DEFAULT #{property.default_value}" if property.has_default_value?
        result
      end
      foreign_sql = @properties.map do |property|
        next unless property.is_foreign?
        reference_table_name = property.type.tableize
        "FOREIGN KEY(#{property.name}) REFERENCES #{reference_table_name}(_id)"
      end

      table + "(_id INTEGER PRIMARY KEY, #{(main_sql + foreign_sql).compact.join(", ")});"

    end

    private

    def key_value_pairs_with_property(properties, cast = false)
      properties.map do |property|
        if cast
          "#{property.name}: #{property.type_without_optional}(#{property.name})"
        else
          "#{property.name}: #{property.name}"
        end
      end.join(", ")
    end

    def key_type_pairs_with_property(properties)
      properties.map do |property|
        has_default_value = property.has_default_value?
        default_value = property.type_without_optional == "String" ? "\"#{property.default_value}\"" : property.default_value
        "#{property.name} #{property.name}: #{property.type.to_s}#{if has_default_value then " = " + "#{default_value}" end}"
      end.join(", ")
    end

  end

end
