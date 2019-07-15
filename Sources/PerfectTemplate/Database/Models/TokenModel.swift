//
//  TokenModel.swift
//  COpenSSL
//
//  Created by Julian Amortegui on 4/8/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

struct TokenTableModel: Codable, TableNameProvider {
    
    private enum Config {
        static let tableName = "token"
    }
    
    static var tableName = Config.tableName
    
    let id: UUID
    let date: Date
    let userId: Int
    let currentToken: String
    let previousToken: String?
    let validToken: Bool
    
    init(userId: Int, currentToken: String, previousToken: String?) {
        id = UUID()
        date = Date()
        validToken = true
        self.userId = userId
        self.currentToken = currentToken
        self.previousToken = previousToken
    }
    
}
