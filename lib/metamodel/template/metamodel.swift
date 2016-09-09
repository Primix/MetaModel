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

func executeSQL(sql: String, verbose: Bool = false, success: (() -> ())? = nil) -> Statement? {
    if verbose {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    do {
        let result = try db.run(sql)
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000

        if verbose {
            print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
            print("-> Commit Transaction")
            print("\n")
        }
        if let success = success {
            success()
        }

        return result
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("\t\(error)")
        if verbose {
            print("-> Rollback transaction")
            print("\n")
        }
    }
    return nil
}

func executeScalarSQL(sql: String, verbose: Bool = false, success: (() -> ())? = nil) -> Binding? {
    if verbose {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    let result = db.scalar(sql)
    let endDate = NSDate()
    let interval = endDate.timeIntervalSinceDate(startDate) * 1000
    if verbose {
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("-> Commit Transaction")
        print("\n")
    }

    if let success = success {
        success()
    }

    return result
}
