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
