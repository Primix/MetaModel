//
//  <%= association.class_name %>.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

typealias <%= association.reverse_class_name %> = <%= association.class_name %>

struct <%= association.class_name %> {
    var privateId: Int = 0
    var <%= association.major_model_id %>: Int = 0
    var <%= association.secondary_model_id %>: Int = 0

    enum Association: String, CustomStringConvertible {
        case privateId = "private_id"
        case <%= association.major_model_id %> = "<%= association.major_model_id.underscore %>"
        case <%= association.secondary_model_id %> = "<%= association.secondary_model_id.underscore %>"
        var description: String { get { return self.rawValue } }
    }
    <% [association.major_model, association.secondary_model].zip([association.secondary_model, association.major_model]).each do |first, second| %>
    static func fetch<%= first.table_name.camelize %>(<%= second.foreign_id %>: Int, first: Bool = false) -> [<%= first.name %>] {
        var query = "SELECT * FROM <%= first.table_name %> WHERE <%= first.table_name %>.private_id IN (" +
            "SELECT private_id " +
            "FROM \(tableName) " +
            "WHERE \(Association.<%= second.foreign_id %>) = \(<%= second.foreign_id %>)" +
        ")"
        if first { query += "LIMIT 1" }
        return MetaModels.fromQuery(query)
    }
    <% end %><% [association.major_model, association.secondary_model].each do |model| %>
    static func findBy(<%= model.foreign_id %>: Int) -> [<%= association.class_name %>] {
        let query = "SELECT * FROM \(tableName) WHERE <%= model.foreign_id.underscore %> = \(<%= model.foreign_id %>)"
        return MetaModels.fromQuery(query)
    }
    <% end %>
    var delete: Void {
        get {
            executeSQL("DELETE * FROM \(<%= association.class_name %>.tableName) WHERE private_id = \(privateId)")
        }
    }
}

extension <%= association.class_name %> {
    static func create(<%= association.major_model_id %>: Int, <%= association.secondary_model_id %>: Int) {
        executeSQL("INSERT INTO \(<%= association.class_name %>.tableName) (<%= association.major_model_id.underscore %>, <%= association.secondary_model_id.underscore %>) VALUES (\(<%= association.major_model_id %>), \(<%= association.secondary_model_id %>))")
    }
}

extension <%= association.class_name %> {
    static let tableName = "<%= association.class_name.underscore %>"
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE \(tableName)(" +
          "private_id INTEGER PRIMARY KEY, " +
          "<%= association.major_model_id.underscore %> INTEGER NOT NULL, " +
          "<%= association.secondary_model_id.underscore %> INTEGER NOT NULL, " +
          "FOREIGN KEY(<%= association.major_model_id.underscore %>) REFERENCES <%= association.major_model.table_name %>(private_id)," +
          "FOREIGN KEY(<%= association.secondary_model_id.underscore %>) REFERENCES <%= association.secondary_model.table_name %>(private_id)" +
        ");"

        executeSQL(initializeTableSQL)
        initializeTrigger()
    }

    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName)"
        executeSQL(dropTableSQL)
        deinitializeTrigger()
    }

    static func initializeTrigger() {
        let majorDeleteTrigger = "CREATE TRIGGER <%= association.major_model.name.underscore %>_delete_trigger " +
            "AFTER DELETE ON <%= association.major_model.table_name %> " +
            "FOR EACH ROW BEGIN " +
                "DELETE FROM \(tableName) WHERE private_id = OLD.private_id; " +
            "END;";

        let secondaryDeleteTrigger = "CREATE TRIGGER <%= association.secondary_model.name.underscore %>_delete_trigger " +
            "AFTER DELETE ON <%= association.secondary_model.table_name %> " +
            "FOR EACH ROW BEGIN " +
                "DELETE FROM \(tableName) WHERE private_id = OLD.private_id; " +
            "END;";

        executeSQL(majorDeleteTrigger)
        executeSQL(secondaryDeleteTrigger)
    }

    static func deinitializeTrigger() {
        let dropMajorTrigger = "DROP TRIGGER IF EXISTS <%= association.major_model.name.underscore %>_delete_trigger;"
        executeSQL(dropMajorTrigger)

        let dropSecondaryTrigger = "DROP TRIGGER IF EXISTS <%= association.secondary_model.name.underscore %>_delete_trigger;"
        executeSQL(dropSecondaryTrigger)
    }
}

public extension <%= association.major_model.name %> {
    var <%= association.name %>: [<%= association.secondary_model.name %>] {
        get {
            return <%= association.class_name %>.fetch<%= association.secondary_model.name.tableize.camelize %>(<%= association.major_model.foreign_id %>: privateId)
        }
        set {
            <%= association.class_name %>.findBy(<%= association.major_model_id %>: privateId).forEach { $0.delete }
            newValue.forEach { <%= association.class_name %>.create(<%= association.major_model_id %>: privateId, <%= association.secondary_model_id %>: $0.privateId) }
        }
    }

    @discardableResult func create<%= association.secondary_model.name %>(<%= association.secondary_model.property_key_type_pairs %>) -> <%= association.secondary_model.name %>? {
        guard let result = <%= association.secondary_model.name %>.create(<%= association.secondary_model.property_key_value_pairs %>) else { return nil }
        <%= association.class_name %>.create(<%= association.major_model_id %>: privateId, <%= association.secondary_model_id %>: result.privateId)
        return result
    }

    @discardableResult func append<%= association.secondary_model.name %>(<%= association.secondary_model.property_key_type_pairs %>) -> <%= association.secondary_model.name %>? {
        return create<%= association.secondary_model.name %>(<%= association.secondary_model.property_key_value_pairs %>)
    }
}
