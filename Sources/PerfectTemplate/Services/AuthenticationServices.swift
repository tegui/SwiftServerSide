//
//  AuthenticationServices.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/8/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

typealias IdTokenResponse = (Result<Int?, RequestError>)
typealias TokenResponse = (Result<String?, RequestError>)

struct AuthenticationServices {
    
    static func saveToken(_ token: String, with id: Int) -> IdTokenResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let tokenTable = try? db.create(TokenTableModel.self) else {
                
                return .failure(.internalError)
        }
        
        let tokenRequest = getTokenById(id)
        
        switch tokenRequest {
        case .success(let dbToken):
            if let previousToken = dbToken, previousToken != token {
                let tokenUpdated = updateToken(token, lastToken: previousToken, with: id)
                return tokenUpdated
            }
        case .failure(_):
            break
        }
        
        do {
            try db.transaction {
                let newTokenData = TokenTableModel(userId: id, currentToken: token, previousToken: nil)
                try tokenTable.insert(newTokenData)
            }
        } catch {
            return .failure(.internalError)
        }
        
        return .success(id)
    }
    
    static func updateToken(_ newToken: String, lastToken: String, with id: Int) -> IdTokenResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let tokenTable = try? db.create(TokenTableModel.self) else {
                
                return .failure(.internalError)
        }
        
        do {
            try db.transaction {
                let newTokenData = TokenTableModel(userId: id, currentToken: newToken, previousToken: lastToken)
                try tokenTable.where(\TokenTableModel.userId == id).update(newTokenData)
            }
        } catch {
            return .failure(.internalError)
        }
        
        return .success(id)
    }
    
    static func getTokenById(_ id: Int) -> TokenResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let tokenTable = try? db.create(TokenTableModel.self) else {
                return .failure(.internalError)
        }
        var token: String?
        do {
            try db.transaction({
                let selectQuery = try tokenTable.where(\TokenTableModel.userId == id).select()
                
                let _ = selectQuery.map({ token = $0.currentToken })
            })
        } catch {
            return .failure(.invalidToken)
        }
        
        return .success(token)
    }
}
