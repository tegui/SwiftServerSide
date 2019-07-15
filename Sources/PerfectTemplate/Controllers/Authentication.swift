//
//  Authentication.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/4/19.
//

import Foundation
import PerfectHTTP

typealias ValidUserResponse = (Result<Bool, RequestError>)

struct Authentication {
    
    private enum Config {
        static let bearerTokenKey = "bearerToken"
    }
    
    static func getSessionToken(request: HTTPRequest) -> String? {
        return UUID().description
    }
    
    static func isUserAuthenticated(request: HTTPRequest) -> ValidUserResponse {
        guard let bearerToken = request.header(.custom(name: Config.bearerTokenKey)),
            let userId = request.session?.userid ,
            let id = Int(userId) else {
            return .failure(.invalidSessionToken)
        }
        
        let status = isValidUser(with: id, token: bearerToken)
        
        switch status {
        case .success(let isValidData):
            return .success(isValidData)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    static func isValidUser(with id: Int, token: String) -> ValidUserResponse {
        let currentToken = AuthenticationServices.getTokenById(id)
        
        switch currentToken {
        case .success(let tokenResponse):
            if tokenResponse == token {
                return .success(true)
            }
        case .failure(let error):
            return .failure(error)
        }
        
        return .failure(.invalidToken)
    }
}
