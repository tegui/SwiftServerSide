//
//  DatabaseManager.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/13/19.
//

//import Foundation
//import PerfectCRUD
//import PerfectSQLite

//struct DatabaseManager {
//
//    private enum Config {
//        static let dbPath               = "/tmp/crud_test.db"
//        static let createUserTable      = "CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY NOT NULL, fullName TEXT NOT NULL)"
//        static let createAddressTable   = "CREATE TABLE IF NOT EXISTS address(id INTEGER PRIMARY KEY NOT NULL, street TEXT NOT NULL, city TEXT NOT NULL, country TEXT NOT NULL, userId INTEGER NOT NULL);"
//        static let databaseErrorMsg     = "Database Error"
//    }
//
//    // MARK: Main database operations
//
//    func createDatabase() {
//        guard let db = try? SQLite(Config.dbPath) else {
//            print(Config.databaseErrorMsg)
//            return
//        }
//
//        let createSource = [Config.createUserTable, Config.createAddressTable]
//
//        for item in createSource {
//            guard let _ = try? db.execute(statement: item) else {
//
//                print("Failure creating Table")
//                db.closeDatabase()
//                return
//            }
//        }
//
//        db.closeDatabase()
//    }
//
//    func dropTable() {
//        guard let db = try? SQLite(Config.dbPath) else {
//            print(Config.databaseErrorMsg)
//            return
//        }
//
//        guard let _ = try? db.execute(statement: "DROP TABLE user") else {
//
//            print("Failure drop table")
//            db.closeDatabase()
//            return
//        }
//
//        db.closeDatabase()
//    }
//
//    private func executeQuery(with query: String) -> Bool {
//        guard
//            let db = try? SQLite(Config.dbPath),
//            let _ = try? db.execute(statement: query) else {
//
//            return false
//        }
//
//        db.closeDatabase()
//        return true
//    }
//
//    // MARK: CRUD functions
//
//    static func retrieveData(with statement: String) -> [[String: Any]]?  {
//        var result = [[String: Any]]()
//
//        guard let db = try? SQLite(Config.dbPath) else {
//            return nil
//        }
//
//        do {
//            try db.forEachRow(statement: statement) { (statement: SQLiteStmt, i: Int) -> () in
//                var tempData = [String: Any]()
//
//                for item in 0...(statement.columnCount()-1) {
//                    tempData[statement.columnName(position: item)] = statement.columnText(position: item)
//                }
//
//                result.append(tempData)
//            }
//
//            db.closeDatabase()
//
//            return result
//        } catch {
//            return nil
//        }
//    }
//
//    func insertData(in table: String, with values: [String: Any]) -> Bool {
//        var columns = ""
//        var columnValues = ""
//
//        for value in values {
//            columns = "\(columns)\(value.key),"
//            columnValues = "\(columnValues)\(value.value),"
//        }
//
//        columns = "(\(columns.replacingLastOccurrenceOfString(",", with: "", caseSensitive: true)))"
//        columnValues = "(\(columnValues.replacingLastOccurrenceOfString(",", with: "", caseSensitive: true)))"
//
//        let query = "INSERT INTO \(table)\(columns) VALUES\(columnValues)"
//        print(query)
//
//        let queryExecution = executeQuery(with: query)
//        return queryExecution
//    }
//
//    func updateUser(in table: String, by id: Int, with values: [String: Any]) -> Bool {
//        var setStatement = ""
//
//        for item in values {
//            setStatement = "\(item.key) = \(item.value)"
//        }
//
//        setStatement = "\(setStatement.replacingLastOccurrenceOfString(",", with: "", caseSensitive: true))"
//        print("statement -> \(setStatement)")
//        let query = "UPDATE \(table) SET \(setStatement) WHERE \(table).id = \(id)"
//
//        let queryExecution = executeQuery(with: query)
//        return queryExecution
//    }
//
//    func obtainUserData(by id: Int) -> [User]? {
//        let query = "SELECT * FROM user WHERE id = \(id)"
//
//        guard let userData = DatabaseManager.retrieveData(with: query) else {
//            return nil
//        }
//
//        var response = [User]()
//
//        for item in userData {
//            let addressQuery = "SELECT * FROM address WHERE userId = \(id)"
//
//            let decoder = JSONDecoder()
//
//            guard
//                let json = try? JSONSerialization.data(withJSONObject: item, options: []),
//                let addressData = DatabaseManager.retrieveData(with: addressQuery),
//                var user = try? decoder.decode(User.self, from: json) else {
//                    return nil
//            }
//
//            for addressItem in addressData {
//                if
//                    let json = try? JSONSerialization.data(withJSONObject: addressItem, options: []),
//                    let address = try? decoder.decode(Address.self, from: json) {
//
//                    user.address = address
//                }
//            }
//
//            response.append(user)
//        }
//
//        return response
//    }
//
//    // MARK: Auxiliary methods
//
//
//    func createAddress() {
//        let _ = insertData(in: "address", with: ["id": 1, "street": "Bogota DC", "city": "Bogota DC", "country": "CO", "userId": 1])
//    }
//}
//
//extension SQLite {
//    func closeDatabase() {
//        defer {
//            self.close()
//        }
//    }
//}
