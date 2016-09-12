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

        let _id: Int64 = values[0] as! Int64
        self._id = Int(_id)
    }
}

extension <%= model.name %> {
    var itself: String { get { return "WHERE \(<%= model.name %>.tableName.unwrapped).\("_id".unwrapped) = \(_id)" } }
}

extension <%= model.relation_name %> {
    func find(_id: Int) -> Self {
        return filter(_id)
    }

    func filter(_id: Int) -> Self {
        self.filter.append("\"_id\" = \(_id)")
        return self
    }
}
