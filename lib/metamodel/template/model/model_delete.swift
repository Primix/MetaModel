// MARK: - Delete

public extension <%= model.name %> {
    var delete: Void {
        get {
            let deleteSQL = "DELETE FROM \(<%= model.name %>.tableName) \(itself)"
            executeSQL(deleteSQL)
        }
    }
    static var deleteAll: Void { get { return <%= model.relation_name %>().deleteAll } }
}

public extension <%= model.relation_name %> {
    var delete: Void { get { return deleteAll } }

    var deleteAll: Void {
        get {
            self.result.forEach { $0.delete }
        }
    }
}
