//
//  User.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/26/19.
//

import Foundation

struct User: Codable {
    let id: Int
    let fullName: String?
    let email: String?
    let password: String?
    var address: Address?
    
    init(id: Int, fullName: String? = nil, email: String?, password: String?) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.password = password
    }
    
    init(id: Int) {
        self.id = id
        fullName = nil
        email = nil
        password = nil
    }
    
    init(from userTable: UserTableModel) {
        self.id = userTable.id
        self.fullName = userTable.fullName
        
        var tempemail: String? = nil
        var temppass : String? = nil
        
        if let auth = userTable.authentication {
            for item in auth {
                temppass = item.password
                tempemail = item.email
            }
        }
        
        self.email = tempemail
        self.password = temppass
        
        
        if let address = userTable.address {
            for item in address {
                self.address = Address(with: item)
            }
        }
    }
    
    func decodeObject() -> [String: Any]? {
        let encoder = JSONEncoder()
        
        guard
            let jsonEncoder = try? encoder.encode(self),
            let json = try? JSONSerialization.jsonObject(with: jsonEncoder, options: []) else {
            return nil
        }
        
        return (json as? [String: Any])
    }
}

struct Address: Codable {
    let street: String?
    let city: String?
    let province: String?
    let country: String?
    let postalCode: String?
    let phone: Int?
    
    init(with address: AddressTableModel?) {
        street = address?.street
        city = address?.city
        province = address?.province
        country = address?.country
        postalCode = address?.postalCode
        phone = address?.phone
    }
}
