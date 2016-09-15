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
    private var privateId: Int = 0
    private var <%= association.major_model.foreign_id %>: Int = 0
    private var <%= association.secondary_model.foreign_id %>: Int = 0

    enum Association: String {
        case privateId = "private_id"
        case <%= association.major_model.foreign_id %> = "<%= association.major_model.foreign_id.underscore %>"
        case <%= association.secondary_model.foreign_id %> = "<%= association.secondary_model.foreign_id.underscore %>"
    }
    <% [association.major_model, association.secondary_model].each do |model| %>
    <%= """static func findBy#{model.foreign_id.camelize}(#{model.foreign_id}: Int) -> [#{association.class_name}] {
        let query = \"SELECT * FROM \\(tableName) WHERE \\(Association.#{model.foreign_id}) = \\(#{model.foreign_id})\"

        var models: [#{association.class_name}] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = #{association.class_name})(values: values)
            models.append(association)
        }
        return models
    }""" %>
    <% end %>
}

extension <%= association.class_name %> {
    init(values: Array<Optional<Binding>>) {
        let privateId: Int64 = values[0] as! Int64
        let <%= association.major_model.foreign_id %>: Int64 = values[1] as! Int64
        let <%= association.secondary_model.foreign_id %>: Int64 = values[2] as! Int64

        self.init(privateId: Int(privateId), <%= association.major_model.foreign_id %>: Int(<%= association.major_model.foreign_id %>), <%= association.secondary_model.foreign_id %>: Int(<%= association.secondary_model.foreign_id %>))
    }
}

extension <%= association.class_name %> {

    static let tableName = "<%= association.class_name.underscore %>"
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE \(tableName)(" +
          "private_id INTEGER PRIMARY KEY, " +
          "<%= association.major_model.foreign_id.underscore %> INTEGER NOT NULL, " +
          "<%= association.secondary_model.foreign_id.underscore %> INTEGER NOT NULL, " +
          "FOREIGN KEY(<%= association.major_model.foreign_id.underscore %>) REFERENCES <%= association.major_model.table_name %>(private_id)," +
          "FOREIGN KEY(<%= association.secondary_model.foreign_id.underscore %>) REFERENCES <%= association.secondary_model.table_name %>(private_id)" +
        ");"

        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName)"
        executeSQL(dropTableSQL)
    }
}
