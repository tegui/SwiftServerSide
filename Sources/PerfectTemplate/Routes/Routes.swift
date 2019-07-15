//
//  Routes.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/2/19.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib

class PerfectRoutes {
    
    private enum Config {
        static let apiRoute         = "/api"
        static let apiGetUser       = "/users/{id}"
        static let apiGetUsers      = "/users/"
        static let apiPostUser      = "/user/"
        static let separatorKey     = "/"
        static let webrootName      = "./webroot"
        static let apiAuth          = "/user/authentication"
        static let apiGetPet        = "/pets/{id}"
        static let apiPostPet       = "/pet/"
    }
    
    static let shared = PerfectRoutes()
    
    var basicRoutes = Routes()
    var apiRoutes = Routes(baseUri: Config.apiRoute)
    
    init() {
        setupBasicRoutes()
        setupApiRoutes()
    }
    
    func setupBasicRoutes() {
        basicRoutes.add(method: .get, uri: Config.separatorKey, handler: handler)
        basicRoutes.add(method: .get, uri: "/**", handler: StaticFileHandler(documentRoot: Config.webrootName, allowResponseFilters: true).handleRequest)
    }

    func setupApiRoutes() {
        apiRoutes.add(method: .get, uri: Config.apiGetUser, handler: UserController.retrieveUsersData)
        apiRoutes.add(method: .get, uri: Config.apiGetUsers, handler: UserController.retrieveUsersData)
        apiRoutes.add(method: .post, uri: Config.apiPostUser, handler: UserController.saveUser)
        apiRoutes.add(method: .put, uri: Config.apiPostUser, handler: UserController.saveUser)
        apiRoutes.add(method: .post, uri: Config.apiAuth, handler: UserController.authenticate)
        apiRoutes.add(method: .get, uri: Config.apiGetPet, handler: AnimalController.retrievePetsData)
        apiRoutes.add(method: .post, uri: Config.apiPostPet, handler: AnimalController.savePet)
        
        basicRoutes.add(apiRoutes)
    }
}
