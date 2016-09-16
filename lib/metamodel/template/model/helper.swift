// MAKR: - Helper

public class <%= model.relation_name %>: Relation<<%= model.name %>> {
    override init() {
        super.init()
        self.select = "SELECT \(<%= model.name %>.tableName).* FROM \(<%= model.name %>.tableName)"
    }

    override var result: [<%= model.name %>] {
        get {
            return MetaModels.fromQuery(query)
        }
    }

    func expandColumn(column: <%= model.name %>.Column) -> String {
        return "\(<%= model.name %>.tableName).\(column)"
    }
}

extension <%= model.name %> {
    var itself: String { get { return "WHERE \(<%= model.name %>.tableName).private_id = \(privateId)" } }
}

extension <%= model.relation_name %> {
    func find(privateId: Int) -> Self {
        return filter(privateId)
    }

    func find(privateIds: [Int]) -> Self {
        return filter([.privateId: privateIds])
    }

    func filter(privateId: Int) -> Self {
        self.filter.append("private_id = \(privateId)")
        return self
    }
}
