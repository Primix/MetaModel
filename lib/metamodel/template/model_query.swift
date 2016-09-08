public extension <%= model.name %> {
    static var all: <%= model.relation_name %> {
        get { return <%= model.relation_name %>() }
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

    <% model.properties_exclude_id.each do |property| %><%= """static func findBy(#{property.name} #{property.name}: #{property.type_without_optional}) -\> #{model.name}? {
        return #{model.relation_name}().findBy(#{property.name}: #{property.name}).first
    }""" %>
    <% end %>
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
