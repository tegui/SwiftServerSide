//
//  UserService.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/3/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

struct UserServices {
    
    static func authentication(data: [String: Any]) -> UserResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let userTable = try? db.create(UserTableModel.self),
            let email = data["email"] as? String else {
                
                return .failure(.internalError)
        }
        
        var user: User?
        do {
            try db.transaction({
                let selectQuery = try userTable.join(\.authentication, on: \.id, equals: \.parentId).where(\AuthenticationUser.email == email).select()
                
                let _ = selectQuery.map{ user = User(from: $0) }
                
            })
        } catch {
            return .failure(.notFound)
        }
        
        return .success(user)
    }
    
    static func addUser(_ user: User) -> UserResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let userTable = try? db.create(UserTableModel.self) else {
                
                return .failure(.internalError)
        }
        
        var result: User?
        
        do {
            let addressTable = db.table(AddressTableModel.self)
            let authTable = try db.create(AuthenticationUser.self, primaryKey: \.email)
            do {
                try addressTable.index(\.parentId)
                try authTable.index(\.parentId)
                try authTable.index(\.id)
            }
            
            try db.transaction {
                let newUser = UserTableModel(from: user)
                try userTable.insert(newUser, ignoreKeys: \.address)//.insert(newUser)
                
                if let address = user.address {
                    let newAddress = AddressTableModel(with: address, parentId: newUser.id)
                    try addressTable.insert([newAddress])
                }
                
                if let _ = user.password {
                    let aut = AuthenticationUser(from: user, parentId: newUser.id)
                    try authTable.index(unique: true, \.email)
                    try authTable.insert([aut])
                }
                
                let queryResponse = try userTable.join(\.address, on: \.id, equals: \.parentId).where(\UserTableModel.id == user.id).select()
                let trrr = try authTable.select()
                print(trrr.map({$0}))
                let _ = queryResponse.map { (iteratedUser) in
                    result = User(from: iteratedUser)
                }
            }
        } catch {
            print(error.localizedDescription)
            return .failure(.existenceData)
        }
        
        return .success(result)
    }
    
    static func updateUserById(_ id: Int, newData: User) -> UserResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase() else {
                
                return .failure(.internalError)
        }
        let newUserData = UserTableModel(from: newData)
        var user: User?
        do {
            let addressTable = db.table(AddressTableModel.self)
            do {
                try addressTable.index(\.parentId)
            }
            
            user = try db.transaction({
                
                if let address = newData.address {
                    let newAddress = AddressTableModel(with: address, parentId: id)
                    try addressTable.insert([newAddress])
                }
                
                try db.table(UserTableModel.self)
                    .where(\UserTableModel.id == id)
                    .update(newUserData, setKeys: \.fullName)
                
                return User(from: newUserData)
            })
        } catch {
            return .failure(.notFound)
        }
        
        return .success(user)
    }
    
    static func getAllUsers() -> UsersResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let userTable = try? db.create(UserTableModel.self) else {
                
                return .failure(.internalError)
        }
        
        var users: [User]?
        
        do {
            try db.transaction({
                let selectQuery = try userTable.join(\.address, on: \.id, equals: \.parentId).select()
                
                let usersData = selectQuery.map{ $0 }
                
                users = []
                
                for user in usersData {
                    let newUser = User(from: user)
                    users?.append(newUser)
                }
            })
        } catch {
            return .failure(.internalError)
        }
        
        return .success(users)
    }
    
    static func getUserById(_ id: Int) -> UserResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let userTable = try? db.create(UserTableModel.self) else {
                
                return .failure(.internalError)
        }
        
        var user: User?
        do {
            try db.transaction({
                let selectQuery = try userTable.join(\.address, on: \.id, equals: \.parentId).join(\.authentication, on: \.id, equals: \.parentId).where(\UserTableModel.id == id).select()
                
                let _ = selectQuery.map{ user = User(from: $0) }
            })
        } catch {
            return .failure(.notFound)
        }
        
        return .success(user)
    }
}
