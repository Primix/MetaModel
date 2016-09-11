//
//  MetaModel.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 MetaModel. All rights reserved.
//

import Foundation

let path = NSSearchPathForDirectoriesInDomains(
    .DocumentDirectory, .UserDomainMask, true
).first! as String

let db =  try! Connection("\(path)/metamodel_db.sqlite3")

public class MetaModel {
    public static func initialize() {
        validateMetaModelTables()
    }
    static func validateMetaModelTables() {
        createMetaModelTable()
        let infos = retrieveMetaModelTableInfos()
        <% models.each do |model| %><%= """if infos[#{model.name}.tableName] != \"#{model.hash_value}\" {
            updateMetaModelTableInfos(#{model.name}.tableName, hashValue: \"#{model.hash_value}\")
            #{model.name}.deinitialize()
            #{model.name}.initialize()
        }""" %>
        <% end %>
    }
}
