// MARK: - Update

public extension <%= model.name %> {
    mutating func update(<%= model.property_exclude_id_key_type_pairs(true, true) %>) {
        var attributes: [<%= model.name %>.Column: Any] = [:]
        <% model.properties_exclude_id.each do |property| %><%= "if (#{property.name} != #{property.type_without_optional}DefaultValue) { attributes[.#{property.name}] = #{property.name} }" %>
        <% end %>
        self.update(attributes)
    }

    mutating func update(attributes: [<%= model.name %>.Column: Any]) {
        var setSQL: [String] = []
        if let attributes = attributes as? [<%= model.name %>.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: setSQL.append(\"\\(key.unwrapped) = \\(value.unwrapped)\")""" %>
                <% end %>default: break
                }
            }
            let updateSQL = "UPDATE \(<%= model.name %>.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
            executeSQL(updateSQL) {
                for (key, value) in attributes {
                    switch key {
                    <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: self.#{property.name} = value as#{property.is_optional? ? "?" : "!"} #{property.type_without_optional}""" %>
                    <% end %>default: break
                    }
                }
            }
        }
    }

    var save: <%= model.name %> {
        mutating get {
            if let _ = <%= model.name %>.find(_id) {
                update([<% column_values = model.properties.map do |property| %><% ".#{property.name}: #{property.name}" %><% end %><%= column_values.join(", ") %>])
            } else {
                <%= model.name %>.create(<%= model.property_key_value_pairs %>)
            }
            return self
        }
    }

    var commit: <%= model.name %> {
        mutating get {
            return save
        }
    }
}

public extension <%= model.relation_name %> {
    public func updateAll(<%= model.property_exclude_id_key_type_pairs(true, true) %>) -> Self {
        return update(<%= model.property_exclude_id_key_value_pairs %>)
    }

    public func update(<%= model.property_exclude_id_key_type_pairs(true, true) %>) -> Self {
        var attributes: [<%= model.name %>.Column: Any] = [:]
        <% model.properties_exclude_id.each do |property| %><%= "if (#{property.name} != #{property.type_without_optional}DefaultValue) { attributes[.#{property.name}] = #{property.name} }" %>
        <% end %>
        result.forEach { (element) in
            var element = element
            element.update(attributes)
        }
        return self
    }
}
