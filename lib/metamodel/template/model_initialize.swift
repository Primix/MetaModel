public struct <%= model.name %> {
    var privateId: Int = 0
    <% model.properties.each do |property| %><%= """public var #{property.name}: #{property.type}""" %>
    <% end %>
    static let tableName = "<%= model.table_name %>"

    public enum Column: String, Unwrapped {
        <% model.properties.each do |property| %><%= """case #{property.name} = \"#{property.name}\"""" %>
        <% end %>
        case privateId = "privateId"
        var unwrapped: String { get { return self.rawValue.unwrapped } }
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
        let insertSQL = "INSERT INTO \(tableName.unwrapped) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL),
          let lastInsertRowId = executeScalarSQL("SELECT last_insert_rowid();") as? Int64 else { return nil }
        var result = <%= model.name %>(<%= model.property_key_value_pairs %>)
        result.privateId = Int(lastInsertRowId)
        return result
    }
}

public extension <%= model.relation_name %> {
    <% model.all_foreign_properties.each do |property| %>
    func create(<%= model.property_key_type_pairs_without_property property.name %>) -> <%= model.name %>? {
        return <%= model.name %>.create(<% if model.properties_exclude_property(property).count == 0 %><%= "#{property}: property" %><% else %><%= model.property_key_value_pairs %><% end %>)
    }

    func append(element: <%= model.name %>) {
        var element = element
        element.<%= property.name %> = <%= property.name %>
    }
    <% end %>
}
