extension <%= model.name %> {
    init(values: Array<Optional<Binding>>) {
        <% model.properties.each_with_index do |property, index| %><%= """let #{property.name}: #{property.real_type} = values[#{index+1}] as! #{property.real_type}""" %>
        <% end %>
        self.init(<%= model.property_key_value_pairs true %>)
    }
}

public class <%= model.relation_name %>: Relation<<%= model.name %>> {
    override init() {
        super.init()
        self.select = "SELECT \(<%= model.name %>.tableName.unwrapped).* FROM \(<%= model.name %>.tableName.unwrapped)"
    }

    override var result: [<%= model.name %>] {
        get {
            var models: [<%= model.name %>] = []
            guard let stmt = executeSQL(query) else { return models }
            for values in stmt {
                models.append(<%= model.name %>(values: values))
            }
            return models
        }
    }

    func expandColumn(column: <%= model.name %>.Column) -> String {
        return "\(<%= model.name %>.tableName.unwrapped).\(column.unwrapped)"
    }

    // MARK: Query

    public func find(id: Int) -> Self {
        return self.findBy(id: id)
    }

    public func findBy(id id: Int) -> Self {
        return self.filter([.id: id]).limit(1)
    }

    <% model.properties_exclude_id.each do |property| %>
    <%= """public func findBy(#{property.name} #{property.name}: #{property.type_without_optional}) -\> Self {
        return self.filter([.#{property.name}: #{property.name}])
    }""" %>
    <% end %>

    public func filter(conditions: [<%= model.name %>.Column: Any]) -> Self {
        for (column, value) in conditions {
            let columnSQL = "\(expandColumn(column))"

            func filterByEqual(value: Any) {
                self.filter.append("\(columnSQL) = \(value)")
            }

            func filterByIn(value: [String]) {
                self.filter.append("\(columnSQL) IN (\(value.joinWithSeparator(", ")))")
            }

            if let value = value as? String {
                filterByEqual(value.unwrapped)
            } else if let value = value as? Int {
                filterByEqual(value)
            } else if let value = value as? Double {
                filterByEqual(value)
            } else if let value = value as? [String] {
                filterByIn(value.map { $0.unwrapped })
            } else if let value = value as? [Int] {
                filterByIn(value.map { $0.description })
            } else if let value = value as? [Double] {
                filterByIn(value.map { $0.description })
            } else {
                let valueMirror = Mirror(reflecting: value)
                print("!!!: UNSUPPORTED TYPE \(valueMirror.subjectType)")
            }

        }
        return self
    }

    public func groupBy(columns: <%= model.name %>.Column...) -> Self {
        return self.groupBy(columns)
    }

    public func groupBy(columns: [<%= model.name %>.Column]) -> Self {
        func groupBy(column: <%= model.name %>.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    public func orderBy(column: <%= model.name %>.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }

    public func orderBy(column: <%= model.name %>.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }

    public func updateAll(column: <%= model.name %>.Column, value: Any) {
        self.result.forEach { (element) in
            var element = element
            element.update([column: value])
        }
    }

    public var deleteAll: Bool {
        get {
            self.result.forEach { $0.delete }
            return true
        }
    }
}
