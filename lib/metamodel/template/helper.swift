// MAKR: - Helper

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
}

extension <%= model.name %> {
    init(values: Array<Optional<Binding>>) {
        <% model.properties.each_with_index do |property, index| %><%= """let #{property.name}: #{property.real_type} = values[#{index+1}] as! #{property.real_type}""" %>
        <% end %>
        self.init(<%= model.property_key_value_pairs true %>)

        let privateId: Int64 = values[0] as! Int64
        self.privateId = Int(privateId)
    }
}

extension <%= model.name %> {
    var itself: String { get { return "WHERE \(<%= model.name %>.tableName.unwrapped).\("private_id".unwrapped) = \(privateId)" } }
}

extension <%= model.relation_name %> {
    func find(privateId: Int) -> Self {
        return filter(privateId)
    }

    func find(privateIds: [Int]) -> Self {
        return filter([.privateId: privateIds])
    }

    func filter(privateId: Int) -> Self {
        self.filter.append("\"private_id\" = \(privateId)")
        return self
    }
}
