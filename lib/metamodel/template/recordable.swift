extension <%= model.name %>: Recordable {
    public init(values: Array<Optional<Binding>>) {
        <% model.properties.each_with_index do |property, index| %><%= """let #{property.name}: #{property.real_type} = values[#{index+1}] as! #{property.real_type}""" %>
        <% end %>
        self.init(id: Int(id)<%= model.property_exclude_id_key_value_pairs(true, true) %>)
    }
}
