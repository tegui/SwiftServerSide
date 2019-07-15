//
//  Animal.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/23/19.
//

import Foundation

struct Pet: Codable {
    var id: UUID
    var name: String?
    var petType: Int?
    
    init(from animalData: AnimalTableModel) {
        self.petType = animalData.animalType
        self.id = animalData.id
        
        guard
            let name = animalData.name else {
                return
        }
        
        self.name = name
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

