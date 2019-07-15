//
//  AnimalTableModel.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/23/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

fileprivate enum TableName: String {
    case animalTable = "animal"
    case relationTable = "userPetRelation"
}

struct AnimalTableModel: Codable, TableNameProvider {
    
    static var tableName = TableName.animalTable.rawValue
    
    var id: UUID
    var name: String?
    var animalType: Int
    
    init(name: String?, animalType: Int) {
        id = UUID()
        self.name = name
        self.animalType = animalType
    }
    
    init(from pet: Pet) {
        id = UUID()
        name = pet.name
        animalType = pet.petType ?? 0
    }
}

struct AnimalType: Codable {
    
    private enum Config {
        
    }
    
    let id: Int
    let name: String
    
    init(from typeId: Int, name: String) {
        id = typeId
        self.name = name
    }
}

struct AnimalUserRelation: Codable, TableNameProvider {
    
    static var tableName = TableName.relationTable.rawValue
    
    var userId: Int
    var animalId: UUID
    
    init(from userId: Int, animalId: UUID) {
        self.userId = userId
        self.animalId = animalId
    }
}
