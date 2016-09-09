public extension <%= model.name %> {
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }

    static var count: Int {
        get {
            let countSQL = "SELECT count(*) FROM \(tableName.unwrapped)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }

    static func new(<%= model.property_key_type_pairs %>) -> <%= model.name %> {
        return <%= model.name %>(<%= model.property_key_value_pairs %>)
    }

    static func create(<%= model.property_key_type_pairs %>) -> <%= model.name %>? {
        if <%= model.properties.select { |p| p.name.downcase.end_with? "id" }.map { |p| "#{p.name} == 0" }.join(" || ") %> { return nil }

        var columnsSQL: [<%= model.name %>.Column] = []
        var valuesSQL: [Unwrapped] = []

        columnsSQL.append(.id)
        valuesSQL.append(id)
        <% model.properties_exclude_id.each do |property| %><% if property.is_optional? %>
        <%= """if let #{property.name} = #{property.name} {
            columnsSQL.append(.#{property.name})
            valuesSQL.append(#{property.name})
        }""" %><% else %>
        <%= """columnsSQL.append(.#{property.name})
        valuesSQL.append(#{property.name})
        """ %><% end %><% end %>

        let insertSQL = "INSERT INTO \(tableName.unwrapped) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL) else { return nil }
        return <%= model.name %>(<%= model.property_key_value_pairs %>)
    }
}
