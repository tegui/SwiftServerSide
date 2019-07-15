//
//  AnimalServices.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/23/19.
//

import Foundation
import PerfectCRUD
import PerfectSQLite

struct AnimalServices {
    
    static func getPet() -> PetResponse  {
        let animalTable = AnimalTableModel(name: "Pelusa", animalType: 2)
        
        let pet = Pet(from: animalTable)
        
        return .success(pet)
    }
    
    static func getAllPets() -> PetsResponse {
        let source = [AnimalTableModel(name: "pelusa", animalType: 2),
                      AnimalTableModel(name: "Kira", animalType: 1),
                      AnimalTableModel(name: "Niño", animalType: 1),
                      AnimalTableModel(name: "Pepe", animalType: 3)]
        
        
        var pets = [Pet]()
        for item in source {
            let pet = Pet(from: item)
            pets.append(pet)
        }
        
        return .success(pets)
    }
    
    static func addPet(_ pet: Pet, by user: User) -> PetResponse {
        guard
            let db = try? DatabaseAdministrator.shared.getDatabase(),
            let petTable = try? db.create(AnimalTableModel.self),
            let userPetRelation = try? db.create(AnimalUserRelation.self) else {
                
                return .failure(.internalError)
        }
        
        var result: Pet?
        
        do {
            try db.transaction {
                let newAnimal = AnimalTableModel(from: pet)
                try petTable.insert(newAnimal)
                
                let animalUserRelation = AnimalUserRelation(from: user.id, animalId: pet.id)
                try userPetRelation.insert(animalUserRelation)
                
                let queryResponse = try petTable.select()
                
                print(queryResponse)
                
                _ = queryResponse.map { (iteratorPet) in
                    result = Pet(from: iteratorPet)
                }
                
            }
            
            
        } catch {
            print(error.localizedDescription)
            return .failure(.existenceData)
        }
        
        return .success(result)
    }
}
