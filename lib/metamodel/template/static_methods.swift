public extension <%= model.name %> {
    static var count: Int {
        get {
            let countSQL = "SELECT count(*) FROM \(tableName)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }
}
