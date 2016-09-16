//
//  Packing.swift
//  MetaModel
//
//  Created by Draveness on 9/16/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

protocol Packing {
    init(values: Array<Optional<Binding>>);
}

class MetaModels {
    static func fromQuery<T where T: Packing>(query: String) -> [T] {
        var models: [T] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = T(values: values)
            models.append(association)
        }
        return models
    }
}

// MARK: - Model Packing
<% models.each do |model| %>
extension <%= model.name %>: Packing {
    init(values: Array<Optional<Binding>>) {
        <% model.properties.each_with_index do |property, index| %><%= """let #{property.name}: #{property.real_type} = values[#{index+1}] as! #{property.real_type}""" %>
        <% end %>
        self.init(<%= model.property_key_value_pairs true %>)

        let privateId: Int64 = values[0] as! Int64
        self.privateId = Int(privateId)
    }
}
<% end %>

// MARK: - Association Packing
<% associations.each do |association| if association.is_active? %>
extension <%= association.class_name %>: Packing {
    init(values: Array<Optional<Binding>>) {
        let privateId: Int64 = values[0] as! Int64
        let <%= association.major_model_id %>: Int64 = values[1] as! Int64
        let <%= association.secondary_model_id %>: Int64 = values[2] as! Int64

        self.init(privateId: Int(privateId), <%= association.major_model_id %>: Int(<%= association.major_model_id %>), <%= association.secondary_model_id %>: Int(<%= association.secondary_model_id %>))
    }
}
<% end %><% end %>
