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
    private var <%= association.major_model.foreignId %>: Int = 0
    private var <%= association.secondary_model.foreignId %>: Int = 0

    static func findBy<%= association.major_model.foreignId.camelize %>(<%= association.major_model.foreignId %>: Int) -> [<%= association.class_name %>] {
        let query = "SELECT * FROM \(tableName) WHERE <%= association.major_model.foreignId %> = \(<%= association.major_model.foreignId %>)"

        var models: [<%= association.class_name %>] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = <%= association.class_name %>(values: values)
            models.append(association)
        }
        return models
    }

    static func findBy<%= association.secondary_model.foreignId.camelize %>(<%= association.secondary_model.foreignId %>: Int) -> [<%= association.class_name %>] {
        let query = "SELECT * FROM \(tableName) WHERE <%= association.secondary_model.foreignId %> = \(<%= association.secondary_model.foreignId %>)"

        var models: [<%= association.class_name %>] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = <%= association.class_name %>(values: values)
            models.append(association)
        }
        return models
    }
}

extension <%= association.class_name %> {
    init(values: Array<Optional<Binding>>) {
        let privateId: Int64 = values[0] as! Int64
        let <%= association.major_model.foreignId %>: Int64 = values[1] as! Int64
        let <%= association.secondary_model.foreignId %>: Int64 = values[2] as! Int64

        self.init(privateId: Int(privateId), <%= association.major_model.foreignId %>: Int(<%= association.major_model.foreignId %>), <%= association.secondary_model.foreignId %>: Int(<%= association.secondary_model.foreignId %>))
    }
}

extension <%= association.class_name %> {

    static let tableName = "<%= association.class_name.underscore %>"
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE \(tableName)(" +
          "private_id INTEGER PRIMARY KEY, " +
          "<%= association.major_model.foreignId %> INTEGER NOT NULL, " +
          "<%= association.secondary_model.foreignId %> INTEGER NOT NULL, " +
          "FOREIGN KEY(<%= association.major_model.foreignId %>) REFERENCES <%= association.major_model.table_name %>(private_id)," +
          "FOREIGN KEY(<%= association.secondary_model.foreignId %>) REFERENCES <%= association.secondary_model.table_name %>(private_id));"

        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}
