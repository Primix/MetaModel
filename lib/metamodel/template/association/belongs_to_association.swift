//
//  <%= association.class_name %>.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

extension <%= association.class_name %> {
    @discardableResult static func create(<%= association.major_model_id %>: Int, <%= association.secondary_model_id %>: Int) {
        executeSQL("INSERT INTO \(<%= association.class_name %>.tableName) (<%= association.major_model_id.underscore %>, <%= association.secondary_model_id.underscore %>) VALUES (\(<%= association.major_model_id %>), \(<%= association.secondary_model_id %>))")
    }
}

public extension <%= association.major_model.name %> {
    var <%= association.name %>: <%= association.secondary_model.name %>? {
        get {
            guard let id = <%= association.class_name %>.findBy(<%= association.major_model.foreign_id %>: privateId).first?.commentId else { return nil }
            return <%= association.secondary_model.name %>.find(id)
        }
        set {
            guard let newValue = newValue else { return }
            <%= association.class_name %>.findBy(<%= association.major_model_id %>: privateId).forEach { $0.delete }
            <%= association.class_name %>.create(<%= association.major_model_id %>: newValue.privateId, <%= association.secondary_model_id %>: privateId)
        }
    }
}
