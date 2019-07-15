//
//  UserController.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/27/19.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib
import PerfectSession

typealias UserResponse = (Result<User?, RequestError>)
typealias UsersResponse = (Result<[User]?, RequestError>)

struct UserController {
    
    private enum Config {
        static let contentType = "application/json"
    }
    
    static func authenticate(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        
        guard
            let bodyString = request.postBodyString,
            let stringDecoded = try? bodyString.jsonDecode(),
            let data = try? JSONSerialization.data(withJSONObject: stringDecoded, options: []),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else {
                
                ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
                return
        }
        
        let result = UserServices.authentication(data: dict)
        
        switch result {
        case .success(let user):
            guard
                let email = dict["email"] as? String,
                let password = dict["password"] as? String,
                let id = user?.id else {
                    
                    ErrorHandler.sendErrorToResponse(response, with: .invalidUser)
                    return
                }
            
            if (user?.email == email && user?.password == password) {
                let tryToken = Authentication.getSessionToken(request: request)
                
                guard let token = tryToken else {
                    ErrorHandler.sendErrorToResponse(response, with: .internalError)
                    return
                }
                
                let saveTokenAction = AuthenticationServices.saveToken(token, with: id)
                switch saveTokenAction {
                case .success(_):
                    break
                case .failure(let error):
                    ErrorHandler.sendErrorToResponse(response, with: error)
                    return
                }
                
                response.request.session?.userid = "\(id)"
                
                requestResponse["message"] = "Authentication success"
                requestResponse["token"] = token
                requestResponse["result"] = ["userId": user?.id]
            }
        case .failure(let error):
            ErrorHandler.sendErrorToResponse(response, with: error)
            return
        }
        
        guard let jsonResponse = try? requestResponse.jsonEncodedString() else {
            ErrorHandler.sendErrorToResponse(response, with: .invalidResponse)
            return
        }
        
        response.setBody(string: jsonResponse)
        response.completed()
    }
    
    static func saveUser(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        
        if request.method == .put {
            updateUser(request: request, response: response)
            return
        }
        let decoder = JSONDecoder()
        
        guard
            let bodyString = request.postBodyString,
            let stringDecoded = try? bodyString.jsonDecode(),
            let data = try? JSONSerialization.data(withJSONObject: stringDecoded, options: []),
            let user = try? decoder.decode(User.self, from: data) else {
                
                ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
                return
        }
        
        let dbExecution = UserServices.addUser(user)
        
        switch dbExecution {
        case .success(let userResult):
            guard let userResult = userResult else {
                ErrorHandler.sendErrorToResponse(response, with: .invalidResponse)
                response.completed()
                return
            }
            
            requestResponse["result"] = userResult.decodeObject()
        case .failure(let error):
            ErrorHandler.sendErrorToResponse(response, with: error)
        }
        
        guard let jsonResponse = try? requestResponse.jsonEncodedString() else {
            ErrorHandler.sendErrorToResponse(response, with: .invalidResponse)
            response.completed()
            return
        }
        
        response.setBody(string: jsonResponse)
        response.completed()
    }
    
    
    static func retrieveUsersData(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: Config.contentType)
        
        switch Authentication.isUserAuthenticated(request: request) {
        case .success(_):
            break
        case .failure(let error):
            ErrorHandler.sendErrorToResponse(response, with: error)
            return
        }
        
        guard let id = request.urlVariables["id"] else {
            ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
            return
        }
        
        let dataRetrieved = retrieveUserByUrlIdentifier(id)
        
        guard let result = dataRetrieved.result else {
            if let error = dataRetrieved.error {
                ErrorHandler.sendErrorToResponse(response, with: error)
            } else {
                ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
            }
            
            return
        }
        
        response.setBody(string: result)
        response.completed()
    }
    
    
    fileprivate static func retrieveUserByUrlIdentifier(_ id: String) -> (result: String?, error: RequestError?) {
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        
        switch id.typeOfRequest() {
        case .singleGet:
            guard let identifier = Int(id), let singleUserData = retrieveUser(with: Int(identifier)) else {
                return (result: nil, error: .notFound)
            }
            
            requestResponse["result"] = singleUserData
        case .multiGet:
            guard let usersData = retrieveAllUsers() else {
                return (result: nil, error: .notFound)
            }
            
            requestResponse["result"] = usersData
        case .errorInUrl:
            return (result: nil, error: .requestFailed)
        }
        
        guard let jsonResponse = try? requestResponse.jsonEncodedString() else {
            return (result: nil, error: .invalidResponse)
        }
        
        return (result: jsonResponse, error: nil)
    }
    
    static func retrieveAllUsers() -> [[String: Any]]? {
        let usersData = UserServices.getAllUsers()
        
        switch usersData {
        case .success(let users):
            guard
                let users = users else {
                    return nil
            }
            
            var response = [[String: Any]]()
            
            for user in users {
                if let userDecoded = user.decodeObject() {
                    response.append(userDecoded)
                }
            }
            
            return response
        case .failure(_):
            return nil
        }
    }
    
    static func retrieveUser(with identifier: Int) -> [String: Any]? {
        let userData = UserServices.getUserById(identifier)
        
        switch userData {
        case .success(let user):
            guard let user = user else {
                return nil
            }
            
            return user.decodeObject()
        case .failure(_):
            return nil
        }
    }
    
    static func updateUser(request: HTTPRequest, response: HTTPResponse) {
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        let decoder = JSONDecoder()
        
        guard
            let bodyString = request.postBodyString,
            let stringDecoded = try? bodyString.jsonDecode(),
            let data = try? JSONSerialization.data(withJSONObject: stringDecoded, options: []),
            let newUser = try? decoder.decode(User.self, from: data) else {
                ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
                return
        }
        
        let updateUser = UserServices.updateUserById(newUser.id, newData: newUser)
        
        switch updateUser {
        case .success(let user):
            guard let user = user else {
                ErrorHandler.sendErrorToResponse(response, with: .internalError)
                response.completed()
                return
            }
            
            requestResponse["result"] = user.decodeObject()
        case .failure(let error):
            ErrorHandler.sendErrorToResponse(response, with: error)
        }
        
        guard let jsonResponse = try? requestResponse.jsonEncodedString() else {
            ErrorHandler.sendErrorToResponse(response, with: .invalidResponse)
            response.completed()
            return
        }
        
        response.setBody(string: jsonResponse)
        response.completed()
    }
    
}
