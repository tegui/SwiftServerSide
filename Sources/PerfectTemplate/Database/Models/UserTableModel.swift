//
//  UserTableModel.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/4/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

fileprivate enum TableName: String {
    case user = "user"
    case address = "address"
}

struct UserTableModel: Codable, TableNameProvider {
    static var tableName = TableName.user.rawValue
    
    let id: Int
    let fullName: String?
    let address: [AddressTableModel]?
    let authentication: [AuthenticationUser]?
    
    init(id: Int, fullName: String? = nil, address: [AddressTableModel]? = nil, auth: [AuthenticationUser]? = nil) {
        self.id = id
        self.fullName = fullName
        self.address = address
        self.authentication = auth
    }
    
    init(from user: User) {
        self.id = user.id
        self.fullName = user.fullName
        
        guard let _ = user.email, let _ = user.password, let address = user.address else {
            authentication = nil
            self.address = nil
            return
        }
        let authData = AuthenticationUser(from: user, parentId: id)
        authentication = [authData]
        
        let newAddress = AddressTableModel(with: address, parentId: id)
        self.address = [newAddress]
        
    }
}

struct AuthenticationUser: Codable {
    let id: UUID
    let parentId: Int
    let email: String?
    let password: String?
    
    init(id: UUID, parentId: Int, email: String, password: String) {
        self.id = id
        self.parentId = parentId
        self.email = email
        self.password = password
    }
    
    init(from user: User, parentId: Int) {
        id = UUID()
        self.parentId = parentId
        
        email = user.email
        password = user.password
    }
}

struct AddressTableModel: Codable {
    let id: UUID
    let parentId: Int
    let street: String?
    let city: String?
    let province: String?
    let country: String?
    let postalCode: String?
    let phone: Int?
    
    init(id: UUID, parentId: Int, street: String?, city: String?, province: String?, country: String?, postalCode: String?, phone: Int?) {
        self.id = id
        self.parentId = parentId
        self.street = street
        self.city = city
        self.province = province
        self.country = country
        self.postalCode = postalCode
        self.phone = phone
    }
    
    init(with address: Address?, parentId: Int) {
        self.parentId = parentId
        id = UUID()
        
        street = address?.street
        city = address?.city
        province = address?.province
        country = address?.country
        postalCode = address?.postalCode
        phone = address?.phone
    }
}
