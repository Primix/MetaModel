public struct <%= model.name %> {
    var privateId: Int = 0
    <% model.properties.each do |property| %><%= """public var #{property.name}: #{property.type}""" %>
    <% end %>
    static let tableName = "<%= model.table_name %>"

    public enum Column: String, CustomStringConvertible {
        <% model.properties.each do |property| %><%= """case #{property.name} = \"#{property.name.underscore}\"""" %>
        <% end %>
        case privateId = "private_id"

        public var description: String { get { return self.rawValue } }
    }

    public init(<%= model.property_key_type_pairs false %>) {
        <% model.properties.each do |property| %><%= """self.#{property.name} = #{property.name}" %>
        <% end %>
    }

    static public func new(<%= model.property_key_type_pairs %>) -> <%= model.name %> {
        return <%= model.name %>(<%= model.property_key_value_pairs %>)
    }

    static public func create(<%= model.property_key_type_pairs %>) -> <%= model.name %>? {
        //if <%= model.properties.select { |p| p.name.downcase.end_with? "id" }.map { |p| "#{p.name} == 0" }.push("false == true").join(" || ") %> { return nil }

        var columnsSQL: [<%= model.name %>.Column] = []
        var valuesSQL: [Unwrapped] = []

        <% model.properties.each do |property| %><% if property.is_optional? %>
        <%= """if let #{property.name} = #{property.name} {
            columnsSQL.append(.#{property.name})
            valuesSQL.append(#{property.name})
        }""" %><% else %>
        <%= """columnsSQL.append(.#{property.name})
        valuesSQL.append(#{property.name})
        """ %><% end %><% end %>
        let insertSQL = "INSERT INTO \(tableName) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL),
          let lastInsertRowId = executeScalarSQL("SELECT last_insert_rowid();") as? Int64 else { return nil }
        var result = <%= model.name %>(<%= model.property_key_value_pairs %>)
        result.privateId = Int(lastInsertRowId)
        return result
    }
}
