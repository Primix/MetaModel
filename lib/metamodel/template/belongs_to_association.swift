//
//  <%= association.class_name %>.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

public extension <%= association.major_model.name %> {
   var <%= association.name %>: <%= association.secondary_model.name %>? {
        get {
            guard let id = <%= association.class_name %>.findBy(<%= association.major_model.foreign_id %>: privateId).first?.commentId else { return nil }
            return <%= association.secondary_model.name %>.find(id)
        }
    }
}
