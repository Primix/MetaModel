// MARK: - Update

public extension <%= model.name %> {
    @discardableResult mutating func update(<%= model.property_exclude_id_key_type_pairs true %>) {
        var attributes: [<%= model.name %>.Column: Any] = [:]
        <% model.properties_exclude_id.each do |property| %><%= "if (#{property.name} != #{property.type_without_optional}DefaultValue) { attributes[.#{property.name}] = #{property.name} }" %>
        <% end %>
        self.update(attributes: attributes)
    }

    @discardableResult mutating func update(attributes: [<%= model.name %>.Column: Any]) {
        var setSQL: [String] = []
        if let attributes = attributes as? [<%= model.name %>.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: setSQL.append(\"\\(key) = \\(value.unwrapped)\")""" %>
                <% end %>default: break
                }
            }
            let updateSQL = "UPDATE \(<%= model.name %>.tableName) SET \(setSQL.joined(separator: ", ")) \(itself)"
            guard let _ = executeSQL(updateSQL) else { return }
            for (key, value) in attributes {
                switch key {
                <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: #{property.name} = value as#{property.is_optional? ? "?" : "!"} #{property.type_without_optional}""" %>
                <% end %>default: break
                }
            }
        }
    }

    var save: <%= model.name %> {
        mutating get {
            if let _ = <%= model.name %>.find(privateId) {
                update(attributes: [<% column_values = model.properties.map do |property| %><% ".#{property.name}: #{property.name}" %><% end %><%= column_values.join(", ") %>])
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
    @discardableResult public func updateAll(<%= model.property_exclude_id_key_type_pairs true %>) -> Self {
        return update(<%= model.property_exclude_id_key_value_pairs %>)
    }

    @discardableResult public func update(<%= model.property_exclude_id_key_type_pairs true %>) -> Self {
        var attributes: [<%= model.name %>.Column: Any] = [:]
        <% model.properties_exclude_id.each do |property| %><%= "if (#{property.name} != #{property.type_without_optional}DefaultValue) { attributes[.#{property.name}] = #{property.name} }" %>
        <% end %>
        result.forEach { (element) in
            var element = element
            element.update(attributes: attributes)
        }
        return self
    }
}
