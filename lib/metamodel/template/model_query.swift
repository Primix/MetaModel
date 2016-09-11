// MARK: - Query

public extension <%= model.name %> {
    static var all: <%= model.relation_name %> {
        get { return <%= model.relation_name %>() }
    }

    static var first: <%= model.name %>? {
        get {
            return <%= model.relation_name %>().orderBy(.id, asc: true).first
        }
    }

    static var last: <%= model.name %>? {
        get {
            return <%= model.relation_name %>().orderBy(.id, asc: false).first
        }
    }

    static func first(length: UInt) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().orderBy(.id, asc: true).limit(length)
    }

    static func last(length: UInt) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().orderBy(.id, asc: false).limit(length)
    }

    static func find(id: Int) -> <%= model.name %>? {
        return <%= model.relation_name %>().find(id).first
    }

    static func findBy(id id: Int) -> <%= model.name %>? {
        return <%= model.relation_name %>().findBy(id: id).first
    }
    <% model.properties_exclude_id.each do |property| %><%= """
    static func findBy(#{property.name} #{property.name}: #{property.type_without_optional}) -\> #{model.name}? {
        return #{model.relation_name}().findBy(#{property.name}: #{property.name}).first
    }
    """ %><% end %>
    static func filter(column: <%= model.name %>.Column, value: Any) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().filter([column: value])
    }

    static func filter(conditions: [<%= model.name %>.Column: Any]) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().filter(conditions)
    }

    static func limit(length: UInt, offset: UInt = 0) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().limit(length, offset: offset)
    }

    static func take(length: UInt) -> <%= model.relation_name %> {
        return limit(length)
    }

    static func offset(offset: UInt) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().offset(offset)
    }

    static func groupBy(columns: <%= model.name %>.Column...) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().groupBy(columns)
    }

    static func groupBy(columns: [<%= model.name %>.Column]) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().groupBy(columns)
    }

    static func orderBy(column: <%= model.name %>.Column) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().orderBy(column)
    }

    static func orderBy(column: <%= model.name %>.Column, asc: Bool) -> <%= model.relation_name %> {
        return <%= model.relation_name %>().orderBy(column, asc: asc)
    }
}

public extension <%= model.relation_name %> {
    func find(id: Int) -> Self {
        return self.findBy(id: id)
    }

    func findBy(id id: Int) -> Self {
        return self.filter([.id: id]).limit(1)
    }

    <% model.properties_exclude_id.each do |property| %><%= """func findBy(#{property.name} #{property.name}: #{property.type_without_optional}) -\> Self {
        return self.filter([.#{property.name}: #{property.name}])
    }""" %>
    <% end %>
    func filter(conditions: [<%= model.name %>.Column: Any]) -> Self {
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

    func groupBy(columns: <%= model.name %>.Column...) -> Self {
        return self.groupBy(columns)
    }

    func groupBy(columns: [<%= model.name %>.Column]) -> Self {
        func groupBy(column: <%= model.name %>.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    func orderBy(column: <%= model.name %>.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }

    func orderBy(column: <%= model.name %>.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }
}
