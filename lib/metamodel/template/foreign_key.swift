// MARK: - Association
<% model.associations.each do |association| %><% if association.has_many? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.secondary_model.relation_name} {
        get {
            var result = #{association.type}.filter(#{model.foreign_id}: privateId)
            result.#{model.foreign_id} = privateId
            return result
        }
        set {
            #{association.name}.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: 0)
            }
            newValue.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: privateId)
            }
            #{association.name}.#{model.foreign_id} = privateId
        }
    }
}""" %><% elsif association.belongs_to? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.type}? {
        get {
            return #{association.secondary_model_instance}
        }
        set {
            guard let newValue = newValue else { return }
            update(#{association.secondary_model.foreign_id}: newValue.privateId)
        }
    }

}""" %><% elsif association.has_one? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.type}? {
        get {
            return #{association.secondary_model_instance}.first
        }
        set {
            #{association.type}.findBy(#{model.foreign_id}: privateId).deleteAll
            guard var newValue = newValue else { return }
            newValue.update(#{model.foreign_id}: privateId)
        }
    }
}"""%><% end %><% end %>
