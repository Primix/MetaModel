public struct <%= model.name %> {
    <% model.properties.each do |property| %><%= """public var #{property.name}: #{property.type}""" %>
    <% end %>
    static let tableName = "<%= model.table_name %>"

    public enum Column: String, Unwrapped {
        <% model.properties.each do |property| %><%= """case #{property.name} = \"#{property.name}\"""" %>
        <% end %>
        var unwrapped: String { get { return self.rawValue.unwrapped } }
    }
}
