// MARK: - Association
<% model.associations.each do |association| %><% if association.has_many? %>
<%= """public extension #{model.name} {
    func append#{association.type}(element: #{association.type}) {
        var element = element
        element.update(#{model.foreign_id}: id)
    }

    func create#{association.type}(#{association.secondary_model.property_key_type_pairs_without_property model.foreign_id}) -> #{association.type}? {
        return #{association.type}.create(#{association.secondary_model.property_key_value_pairs_without_property model.foreign_id}, #{model.foreign_id}: self.id)
    }

    func delete#{association.type}(id: Int) {
        #{association.type}.filter(.#{model.foreign_id}, value: id).findBy(id: id).first?.delete
    }
    var #{association.name}: [#{association.type}] {
        get {
            return #{association.type}.filter(.id, value: id).result
        }
        set {
            #{association.name}.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: 0)
            }
            newValue.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: id)
            }
        }
    }
}""" %><% elsif association.belongs_to? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.type}? {
        get {
            return #{association.type}.find(id)
        }
        set {
            guard let newValue = newValue else { return }
            update(#{association.secondary_model.foreign_id}: newValue.id)
        }
    }

}""" %><% elsif association.has_one? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.type}? {
        get {
            return #{association.type}.find(id)
        }
        set {
            #{association.type}.filter(.#{model.foreign_id}, value: id).deleteAll
            guard var newValue = newValue else { return }
            newValue.update(#{model.foreign_id}: id)
        }
    }
}"""%><% end %><% end %>
