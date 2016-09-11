// MARK: - Delete

public extension <%= model.name %> {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(<%= model.name %>.tableName.unwrapped) \(itself)"
            executeSQL(deleteSQL)
            <% model.associations.select { |a| a.dependent == :destroy }.each do |association| %><%= "#{association.secondary_model.name}.findBy(#{model.foreign_id}: id).delete" %>
            <% end %>return true
        }
    }
    static var deleteAll: Bool { get { return <%= model.relation_name %>().deleteAll } }
}

public extension <%= model.relation_name %> {
    var delete: Bool { get { return deleteAll } }

    var deleteAll: Bool {
        get {
            self.result.forEach { $0.delete }
            return true
        }
    }
}
