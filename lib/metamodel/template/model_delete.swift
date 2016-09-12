// MARK: - Delete

public extension <%= model.name %> {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(<%= model.name %>.tableName.unwrapped) \(itself)"
            executeSQL(deleteSQL)<% model.associations.each do |association| %>
            <%= association.secondary_model_instance + "?.delete" if association.dependent == :destroy %>
            <%= association.secondary_model_instance + "?.update(#{model.foreign_id}: 0)" if association.dependent == :nullify && model.contains?(model.foreign_id) %>
            <% end %>
            return true
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
