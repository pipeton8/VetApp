//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum PetProperties : String {
    case name        = "name"
    case species     = "species"
    case race        = "race"
    case dateOfBirth = "dateOfBirth"
    case chipNumber  = "chipNumber"
    case imagePath   = "imagePath"
    case owners      = "owners"
}

class Pet {
    var name : String = ""
    var species : Species = Species.none
    var race : String = ""
    var dateOfBirth : Int = 0
    var chipNumber : Int = -1
    var imagePath : String = ""
    var owners : [String] = [String]()
    var ID : String = ""
    
    init(dictionary : [String : Any], id : String? = nil) {
        if let name = dictionary[PetProperties.name.rawValue] as? String { self.name = name }
        if let speciesStr = dictionary[PetProperties.species.rawValue] as? String, let species = Species(rawValue: speciesStr) { self.species = species }
        if let race = dictionary[PetProperties.race.rawValue] as? String { self.race = race }
        if let dateOfBirth = dictionary[PetProperties.dateOfBirth.rawValue] as? Int { self.dateOfBirth = dateOfBirth }
        if let chipNumber = dictionary[PetProperties.chipNumber.rawValue] as? Int { self.chipNumber = chipNumber}
        if let imagePath = dictionary[PetProperties.imagePath.rawValue] as? String { self.imagePath = imagePath }
        if let owners = dictionary[PetProperties.owners.rawValue] as? [String] {self.owners = owners}
        if let _ = id { ID = id! } else { generateID() }
    }
    
    func PrepareToUpload() -> [String : Any] {
        return [
                    PetProperties.name.rawValue        : name,
                    PetProperties.species.rawValue     : species.rawValue,
                    PetProperties.race.rawValue        : race,
                    PetProperties.dateOfBirth.rawValue : dateOfBirth,
                    PetProperties.chipNumber.rawValue  : chipNumber,
                    PetProperties.imagePath.rawValue   : imagePath,
                    PetProperties.owners.rawValue      : owners
            ]
    }
    
    func generateID() {
        ID = String(Int(Date.timeIntervalSinceReferenceDate)) + "-" + String(Int.random(in: 0..<1000000))
    }
    
    func addOwner(newOwner : String) {
        owners.append(newOwner)
    }
}
