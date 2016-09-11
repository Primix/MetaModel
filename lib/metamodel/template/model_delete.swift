// MARK: - Delete

public extension <%= model.name %> {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(<%= model.name %>.tableName.unwrapped) \(itself)"
            executeSQL(deleteSQL)
            return true
        }
    }
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }
}

public extension <%= model.relation_name %> {
    var deleteAll: Bool {
        get {
            self.result.forEach { $0.delete }
            return true
        }
    }
}
