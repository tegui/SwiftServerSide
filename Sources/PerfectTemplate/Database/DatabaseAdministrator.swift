//
//  Database.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/4/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

typealias DBConfiguration = SQLiteDatabaseConfiguration

class DatabaseAdministrator {
    
    private enum Config {
        static let databaseName = "/tmp/crud_test.db"
    }
    
    static let shared = DatabaseAdministrator()
    
    func getDatabase(reset: Bool = false) throws -> Database<DBConfiguration> {
        if reset {
            unlink(Config.databaseName)
        }
        
        return Database(configuration: try DBConfiguration(Config.databaseName))
    }
}
