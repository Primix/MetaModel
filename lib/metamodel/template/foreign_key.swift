// MARK: - Association
<% model.associations.each do |association| %><% if association.has_many? %>
<%= """public extension #{model.name} {
    func append#{association.type}(element: #{association.type}) {
        var element = element
        element.update(#{model.foreign_id}: _id)
    }

    func create#{association.type}(#{association.secondary_model.property_key_type_pairs_without_property model.foreign_id}) -> #{association.type}? {""" %>
        return <%= "#{association.type}.create(" %><% if association.secondary_model.properties_exclude_property(model.foreign_id).count == 0 then %><%= "" %><% else %><%= "#{association.secondary_model.property_key_value_pairs_without_property(model.foreign_id)}, #{model.foreign_id}: _id" %><% end %>)
    }
<%= """

    var #{association.name}: #{association.secondary_model.relation_name} {
        get {
            var result = #{association.type}.filter(#{model.foreign_id}: _id)
            result.#{model.foreign_id} = _id
            return result
        }
        set {
            #{association.name}.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: 0)
            }
            newValue.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: _id)
            }
            #{association.name}.#{model.foreign_id} = _id
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
            update(#{association.secondary_model.foreign_id}: newValue._id)
        }
    }

}""" %><% elsif association.has_one? %>
<%= """public extension #{model.name} {
    var #{association.name}: #{association.type}? {
        get {
            return #{association.secondary_model_instance}.first
        }
        set {
            #{association.type}.findBy(#{model.foreign_id}: _id).deleteAll
            guard var newValue = newValue else { return }
            newValue.update(#{model.foreign_id}: _id)
        }
    }
}"""%><% end %><% end %>
