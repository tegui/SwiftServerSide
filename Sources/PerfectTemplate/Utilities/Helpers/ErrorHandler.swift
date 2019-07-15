//
//  ErrorHandler.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/3/19.
//

import Foundation
import PerfectHTTP

typealias errorHandlerResponse = (message: String, code: Int)

struct ErrorHandler {
    
    static func requestErrorHandler(with requestError: RequestError) -> errorHandlerResponse {
        var response: errorHandlerResponse
        
        switch requestError {
        case .existenceData:
            response = (message: "the data you are trying to modify already exist", code: 302)
        case .requestFailed:
            response = (message: "request failed", code: 400)
        case .unauthorized:
            response = (message: "unauthorized request, user or token", code: 401)
        case .notFound:
            response = (message: "data not found", code: 404)
        case .forbiddenData:
            response = (message: "forbidden data", code: 403)
        case .emptyResponse:
            response = (message: "", code: 601)
        case .invalidResponse:
            response = (message: "", code: 602)
        case .internalError:
            response = (message: "", code: 603)
        case .invalidUser:
            response = (message: "authentication failed", code: 604)
        case .invalidToken:
            response = (message: "invalid token", code: 605)
        case .invalidSessionToken:
            response = (message: "invalid session token or header token", code: 606)
        }
        
        return response
    }
    
    static func sendErrorToResponse(_ response:  HTTPResponse, with requestError: RequestError) {
        let errorData = requestErrorHandler(with: requestError)
        
        let responseDictionary: [String: Any] = ["message": errorData.message, "status": errorData.code]
        
        guard let json = try? responseDictionary.jsonEncodedString() else {
            response.completed()
            return
        }
        
        response.setBody(string: json)
        response.completed()
    }
}
