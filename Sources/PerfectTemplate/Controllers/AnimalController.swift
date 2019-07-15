//
//  AnimallController.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/24/19.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib
import PerfectSession

typealias PetResponse = (Result<Pet?, RequestError>)
typealias PetsResponse = (Result<[Pet]?, RequestError>)

struct AnimalController {
    
    private enum Config {
        static let contentType = "application/json"
    }
    
    static func retrievePetsData(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: Config.contentType)
        
        guard let id = request.urlVariables["id"] else {
            ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
            return
        }
        
        let dataRetrieved = retrievePetsByURLIdentifier(id)
        
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
    
    fileprivate static func retrievePet(for user: User) -> [String: Any]? {
        let animalData = AnimalServices.getPet()
        
        switch animalData {
        case .success(let pet):
            guard let pet = pet else {
                return nil
            }
            
            return pet.decodeObject()
        case .failure(_):
            return nil
        }
    }
    
    fileprivate static func retrievePetsByURLIdentifier(_ id: String) -> (result: String?, error: RequestError?) {
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        
        switch id.typeOfRequest() {
        case .singleGet:
            let user = User(id: 5465, email: "mail@mail.com", password: "123456789")
            let pet = retrievePet(for: user)
            
            requestResponse["pet"] = pet
        case .multiGet:
            let pets = retrieveAllPets()
            requestResponse["pets"] = pets
        case .errorInUrl:
            return (result: nil, error: .requestFailed)
        }
        
        guard let jsonResponse = try? requestResponse.jsonEncodedString() else {
            return (result: nil, error: .invalidResponse)
        }
        
        return (result: jsonResponse, error: nil)
    }
    
    static func retrieveAllPets() -> [[String: Any]]? {
        let petsData = AnimalServices.getAllPets()
        
        switch petsData {
        case .success(let pets):
            guard
                let pets = pets else {
                    return nil
            }
            
            var response = [[String: Any]]()
            
            for pet in pets {
                if let userDecoded = pet.decodeObject() {
                    response.append(userDecoded)
                }
            }
            
            return response
        case .failure(_):
            return nil
        }
    }
    
    static func savePet(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var requestResponse: [String: Any?] = ["message": "success", "status": 200]
        
        guard
            let bodyString = request.postBodyString,
            let stringDecoded = try? bodyString.jsonDecode(),
            let data = try? JSONSerialization.data(withJSONObject: stringDecoded, options: []),
            let animalJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let animalName = animalJson?["name"] as? String,
            let animalType = animalJson?["type"] as? Int,
            let userId = animalJson?["user_id"] as? Int else {
                
                ErrorHandler.sendErrorToResponse(response, with: .requestFailed)
                return
        }
        
        let animal = AnimalTableModel(name: animalName, animalType: animalType)
        let newPet = Pet(from: animal)
        
        let newUser = User(id: userId)
        
        let dbExecution = AnimalServices.addPet(newPet, by: newUser)
        
        switch dbExecution {
        case .success(let animalResult):
            guard let animalResult = animalResult else {
                ErrorHandler.sendErrorToResponse(response, with: .invalidResponse)
                response.completed()
                return
            }
            
            requestResponse["result"] = animalResult.decodeObject()
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
