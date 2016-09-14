module MetaModel
  module Record
    class Model
      attr_reader :name
      attr_reader :properties
      attr_reader :associations

      def initialize(name)
        @name = name.to_s.camelize
        @properties = []
        @associations = []
      end

      def contains?(property)
        @properties.select { |prop| prop.name == property }.size > 0
      end

      def properties_exclude_id
        properties_exclude_property "id"
      end

      def properties_exclude_property(property)
        @properties.select { |element| element.name != property }
      end

      def foreign_id
        "#{name}Id".camelize(:lower)
      end

      def table_name
        name.tableize
      end

      def relation_name
        "#{name}Relation"
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

      def property_key_type_pairs(remove_extra_param = true, use_default_value = false)
        key_type_pairs_with_property @properties, remove_extra_param, use_default_value
      end

      def property_exclude_id_key_type_pairs(remove_extra_param = true, use_default_value = false)
        key_type_pairs_with_property properties_exclude_id, remove_extra_param, use_default_value
      end

      def property_key_type_pairs_without_property(property)
        key_type_pairs_with_property @properties.select { |element| element.name != property }
      end

      def build_table
        table = "CREATE TABLE #{table_name}"
        main_sql = @properties.map do |property|
          result = "#{property.name.underscore} #{property.database_type}"
          result << " PRIMARY KEY" if property.is_primary?
          result << " UNIQUE" if property.is_unique?
          result << " DEFAULT #{property.default_value}" if property.has_default_value?
          result
        end
        # foreign_sql = @properties.map do |property|
        #   next unless property.is_foreign?
        #   reference_table_name = property.type.tableize
        #   "FOREIGN KEY(#{property.name}) REFERENCES #{reference_table_name}(privateId)"
        # end

        table + "(private_id INTEGER PRIMARY KEY, #{(main_sql).compact.join(", ")});"
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

      def key_type_pairs_with_property(properties, remove_extra_param = true, use_default_value = false)
        properties.enum_for(:each_with_index).map do |property, index|
          has_default_value = property.has_default_value?
          default_value = property.type_without_optional == "String" ? "\"#{property.default_value}\"" : property.default_value

          result = "#{property.name}: #{property.type.to_s}#{if has_default_value then " = " + "#{default_value}" end}"
          result = "#{property.name}: #{property.type.to_s} = #{property.type_without_optional}DefaultValue" if use_default_value
          if index == 0 && remove_extra_param
            "#{property.name} #{result}"
          else
            result
          end
        end.join(", ")
      end

    end
  end
end
