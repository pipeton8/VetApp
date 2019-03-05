//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

class Pet {
    var name : String = ""
    var species : Species = Species.none
    var race : String = ""
    var dateOfBirth : Int = 0
    var chipNumber : Int = -1
    var imagePath : String = ""
    var ID : String = ""
    
    init(dictionary : [String : Any], id : String?) {
        if let name = dictionary["name"] as? String { self.name = name }
        if let speciesStr = dictionary["species"] as? String, let species = Species(rawValue: speciesStr) { self.species = species }
        if let race = dictionary["race"] as? String { self.race = race }
        if let dateOfBirth = dictionary["dateOfBirth"] as? Int { self.dateOfBirth = dateOfBirth }
        if let chipNumber = dictionary["chipNumber"] as? Int { self.chipNumber = chipNumber}
        if let imagePath = dictionary["imagePath"] as? String { self.imagePath = imagePath }
        if let ID = id { self.ID = ID }
    }
    
    func PrepareToUpload() -> [String : Any] {
        return [
                    "name"        : name,
                    "species"     : species.rawValue,
                    "race"        : race,
                    "dateOfBirth" : dateOfBirth,
                    "chipNumber"  : chipNumber,
                    "imagePath"   : imagePath
            ]
    }
}
