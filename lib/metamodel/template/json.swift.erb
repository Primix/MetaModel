extension <%= model.name %> {
    public static func parse(json: [String: AnyObject]) -> <%= model.name %> {
        let id: Int = json["id"] as! Int
        <% model.properties_exclude_id.each do |property| %>
        <%= """let #{property.name}: #{property.type} = json[\"#{property.name}\"] as! #{property.type}""" %>
        <% end %>
        return <%= model.name %>(<%= model.property_key_value_pairs %>)
    }

    public static func parse(jsons: [[String: AnyObject]]) -> [<%= model.name %>] {
        return jsons.map(<%= model.name %>.parse)
    }

    public static func parse(data: NSData) throws -> <%= model.name %> {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
        return <%= model.name %>.parse(json)
    }

    public static func parses(data: NSData) throws -> [<%= model.name %>] {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [[String: AnyObject]]
        return <%= model.name %>.parse(json)
    }

}
