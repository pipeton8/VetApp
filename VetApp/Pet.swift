//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum Species : String {
    case Cat = "Cat"
    case Dog = "Dog"
}

class Pet {
    var name : String
    var species : Species
    var dateOfBirth : Int // Special format?
    var chipNumber : Int // String maybe?
    var race : String
    
    init(name : String, species : Species, race : String, dateOfBirth : Int,  chipNumber : Int) {
        self.name = name
        self.species = species
        self.race = race
        self.dateOfBirth = dateOfBirth
        self.chipNumber = chipNumber
    }
    
}
